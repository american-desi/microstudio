SYSTEM_PROMPT = """You are the microStudio AI creation assistant. You help students (often kids and teens) create and improve games inside microStudio, a browser game engine. Be encouraging, concise and clear. Never write anything inappropriate for children.

The user's project language is LANGUAGE_NAME. When asked to create or modify code, return the COMPLETE updated content of the current source file in a single fenced code block, so it can be applied directly to the editor. Briefly explain what you changed before the code block. Do not use more than one code block per reply.

microScript 2.0 quick reference (when the project language is microscript):
- The engine calls three global functions: init() once at start, update() 30 times/second (game logic), draw() 60 times/second (rendering).
- No semicolons, blocks end with `end`. Example: `if x > 0 then ... end`, `for i = 1 to 10 ... end`, `while cond ... end`. Functions: `myFunc = function(a, b) ... end`.
- Variables are global unless declared with `local`. Objects: `player = object x = 0, y = 0 end`. Lists: `list = [1, 2, 3]`, `list.push(4)`.
- Screen drawing (in draw()): screen.clear(), screen.fillRect(x, y, w, h, color), screen.fillRound(x, y, w, h, color), screen.drawSprite("name", x, y, w, h), screen.drawText(text, x, y, size, color), screen.drawMap("name", x, y, w, h), screen.setAlpha(a), colors are strings like "#FFF" or "rgb(255, 0, 0)".
- The screen center is x = 0, y = 0; x grows right, y grows UP. Default the shortest screen dimension spans 200 units (-100 to 100).
- Input: keyboard.UP / DOWN / LEFT / RIGHT / SPACE / A .. Z (value 1 while pressed), keyboard.press.SPACE (1 on the frame pressed), touch.touching, touch.x, touch.y, mouse.x, mouse.y, mouse.pressed.
- Sounds and music: audio.playSound("name"), audio.playMusic("name"). Sprites, maps, sounds and music are project assets referenced by name.
- Useful: sprites["name"].width, maps["name"], random.next() (0..1), abs/min/max/floor/round/sqrt/cos/sin (radians via PI), system.time().

Guidance:
- Prefer small, working, playable steps over big rewrites; keep existing code the user did not ask to change.
- If the request is ambiguous, make a sensible choice and note it in one sentence.
- If asked to explain code, explain simply, matched to a young learner.
- If the user asks for sprites or assets you cannot create, use simple drawn shapes instead and say how to add sprites later."""

Anthropic = require "@anthropic-ai/sdk"

class @AIAssistant
  constructor:(@server)->
    @config = @server.config or {}
    @usage = {}
    if @enabled()
      @client = new Anthropic { apiKey: @config.ai_api_key }

  enabled:()->
    @config.ai_api_key? and @config.ai_api_key.length > 0

  # sliding one-hour window, per user
  rateLimited:(user_id)->
    limit = @config.ai_hourly_limit or 40
    now = Date.now()
    list = @usage[user_id] or []
    list = list.filter (t)-> now - t < 3600 * 1000
    @usage[user_id] = list
    list.length >= limit

  recordUse:(user_id)->
    @usage[user_id].push Date.now()

  languageName:(language)->
    switch language
      when "python" then "Python (Brython)"
      when "javascript" then "JavaScript"
      when "lua" then "Lua"
      else "microScript 2.0"

  assist:(user,data,callback)->
    return callback { error: "ai_not_configured" } if not @enabled()
    return callback { error: "ai_rate_limited" } if @rateLimited(user.id)

    messages = []
    if Array.isArray(data.messages)
      for m in data.messages
        if m? and (m.role == "user" or m.role == "assistant") and typeof m.content == "string" and m.content.length > 0
          messages.push { role: m.role, content: m.content.substring(0,20000) }
    messages = messages.slice(-12)
    return callback { error: "ai_empty_request" } if messages.length == 0 or messages[messages.length-1].role != "user"

    context = data.context or {}
    system = SYSTEM_PROMPT.replace "LANGUAGE_NAME",@languageName(context.language)
    if context.file? and context.code?
      system += "\n\nCurrent source file: \"#{("#{context.file}").substring(0,100)}\"\nCurrent content of this file:\n```\n#{("#{context.code}").substring(0,30000)}\n```"

    @recordUse user.id

    @client.messages.create
      model: @config.ai_model or "claude-haiku-4-5"
      max_tokens: @config.ai_max_tokens or 3000
      system: system
      messages: messages
    .then (response)=>
      if response.stop_reason == "refusal"
        return callback { error: "ai_request_failed" }
      text = ""
      for block in response.content
        text += block.text if block.type == "text"
      callback { text: text }
    .catch (err)=>
      console.error "AI assist error: #{err}"
      callback { error: "ai_request_failed" }

module.exports = @AIAssistant

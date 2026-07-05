class @AIAssist
  constructor:(@app)->
    @panel = document.getElementById "ai-panel"
    return if not @panel?
    @messages_div = document.getElementById "ai-messages"
    @status_div = document.getElementById "ai-status"
    @input = document.getElementById "ai-input"
    @send_button = document.getElementById "ai-send"
    @reset_button = document.getElementById "ai-reset"

    @messages = []
    @waiting = false
    @backup_code = null
    @backup_source = null

    @send_button.addEventListener "click",()=>@sendMessage()
    @reset_button.addEventListener "click",()=>@reset()

    @input.addEventListener "keydown",(e)=>
      if e.key == "Enter" and not e.shiftKey
        e.preventDefault()
        @sendMessage()

  projectOpened:()->
    @reset()

  reset:()->
    @messages = []
    @backup_code = null
    @backup_source = null
    @messages_div.innerHTML = ""
    @setStatus ""

  setStatus:(text,error=false)->
    @status_div.innerText = text
    if error
      @status_div.classList.add "error"
    else
      @status_div.classList.remove "error"

  sendMessage:()->
    return if @waiting
    text = @input.value.trim()
    return if text.length == 0

    @input.value = ""
    @messages.push { role: "user", content: text }
    @addBubble "user",[{ type: "text", text: text }]

    context = {}
    if @app.editor.selected_source? and @app.project?
      context =
        file: @app.editor.selected_source
        code: @app.editor.getCode()
        language: @app.project.language

    @waiting = true
    @send_button.classList.add "disabled"
    @setStatus @app.translator.get("Thinking...")

    @app.client.sendRequest {
      name: "ai_assist"
      messages: @messages.slice(-12)
      context: context
    },(msg)=>
      @waiting = false
      @send_button.classList.remove "disabled"
      if msg.name == "error"
        @messages.pop()
        switch msg.error
          when "ai_not_configured"
            @setStatus @app.translator.get("The AI assistant is not configured on this server. Add your API key as \"ai_api_key\" in config.json."),true
          when "ai_rate_limited"
            @setStatus @app.translator.get("You have used the AI assistant a lot this hour! Take a break and try again later."),true
          else
            @setStatus @app.translator.get("Something went wrong, please try again."),true
      else
        @setStatus ""
        @messages.push { role: "assistant", content: msg.text }
        @addBubble "assistant",@parseReply(msg.text)

  # split reply into text and fenced code parts
  parseReply:(text)->
    parts = []
    regex = /```[a-z0-9_]*\n?([\s\S]*?)```/g
    index = 0
    while (match = regex.exec(text))?
      before = text.substring(index,match.index).trim()
      parts.push { type: "text", text: before } if before.length > 0
      code = match[1].replace(/\n$/,"")
      parts.push { type: "code", code: code } if code.length > 0
      index = match.index + match[0].length
    rest = text.substring(index).trim()
    parts.push { type: "text", text: rest } if rest.length > 0
    parts

  addBubble:(role,parts)->
    bubble = document.createElement "div"
    bubble.classList.add "ai-bubble"
    bubble.classList.add "ai-bubble-#{role}"

    for part in parts
      if part.type == "text"
        p = document.createElement "p"
        p.innerText = part.text
        bubble.appendChild p
      else if part.type == "code"
        pre = document.createElement "pre"
        code_element = document.createElement "code"
        code_element.innerText = part.code
        pre.appendChild code_element
        bubble.appendChild pre
        do (part)=>
          apply = document.createElement "div"
          apply.classList.add "button1"
          apply.classList.add "ai-apply-button"
          apply.innerHTML = "<i class='fa fa-magic'></i> "+@app.translator.get("Apply to code editor")
          apply.addEventListener "click",()=>@applyCode(part.code)
          bubble.appendChild apply

    @messages_div.appendChild bubble
    @messages_div.scrollTop = @messages_div.scrollHeight

  applyCode:(code)->
    return if not @app.editor.selected_source?
    @backup_code = @app.editor.getCode()
    @backup_source = @app.editor.selected_source
    @app.editor.setCode code
    @app.editor.editorContentsChanged()
    @app.editor.forceSave()
    @setStatus @app.translator.get("Code applied and saved.")
    @showUndo()

  showUndo:()->
    undo = document.createElement "div"
    undo.classList.add "button1"
    undo.classList.add "ai-undo-button"
    undo.innerHTML = "<i class='fa fa-undo'></i> "+@app.translator.get("Undo last apply")
    undo.addEventListener "click",()=>
      return if not @backup_code? or @app.editor.selected_source != @backup_source
      @app.editor.setCode @backup_code
      @app.editor.editorContentsChanged()
      @app.editor.forceSave()
      @backup_code = null
      undo.remove()
      @setStatus @app.translator.get("Your previous code is back.")
    @messages_div.appendChild undo
    @messages_div.scrollTop = @messages_div.scrollHeight

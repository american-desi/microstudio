var Anthropic, SYSTEM_PROMPT;

SYSTEM_PROMPT = "You are the microStudio AI creation assistant. You help students (often kids and teens) create and improve games inside microStudio, a browser game engine. Be encouraging, concise and clear. Never write anything inappropriate for children.\n\nThe user's project language is LANGUAGE_NAME. When asked to create or modify code, return the COMPLETE updated content of the current source file in a single fenced code block, so it can be applied directly to the editor. Briefly explain what you changed before the code block. Do not use more than one code block per reply.\n\nmicroScript 2.0 quick reference (when the project language is microscript):\n- The engine calls three global functions: init() once at start, update() 30 times/second (game logic), draw() 60 times/second (rendering).\n- No semicolons, blocks end with `end`. Example: `if x > 0 then ... end`, `for i = 1 to 10 ... end`, `while cond ... end`. Functions: `myFunc = function(a, b) ... end`.\n- Variables are global unless declared with `local`. Objects: `player = object x = 0, y = 0 end`. Lists: `list = [1, 2, 3]`, `list.push(4)`.\n- Screen drawing (in draw()): screen.clear(), screen.fillRect(x, y, w, h, color), screen.fillRound(x, y, w, h, color), screen.drawSprite(\"name\", x, y, w, h), screen.drawText(text, x, y, size, color), screen.drawMap(\"name\", x, y, w, h), screen.setAlpha(a), colors are strings like \"#FFF\" or \"rgb(255, 0, 0)\".\n- The screen center is x = 0, y = 0; x grows right, y grows UP. Default the shortest screen dimension spans 200 units (-100 to 100).\n- Input: keyboard.UP / DOWN / LEFT / RIGHT / SPACE / A .. Z (value 1 while pressed), keyboard.press.SPACE (1 on the frame pressed), touch.touching, touch.x, touch.y, mouse.x, mouse.y, mouse.pressed.\n- Sounds and music: audio.playSound(\"name\"), audio.playMusic(\"name\"). Sprites, maps, sounds and music are project assets referenced by name.\n- Useful: sprites[\"name\"].width, maps[\"name\"], random.next() (0..1), abs/min/max/floor/round/sqrt/cos/sin (radians via PI), system.time().\n\nGuidance:\n- Prefer small, working, playable steps over big rewrites; keep existing code the user did not ask to change.\n- If the request is ambiguous, make a sensible choice and note it in one sentence.\n- If asked to explain code, explain simply, matched to a young learner.\n- If the user asks for sprites or assets you cannot create, use simple drawn shapes instead and say how to add sprites later.";

Anthropic = require("@anthropic-ai/sdk");

this.AIAssistant = (function() {
  function AIAssistant(server) {
    this.server = server;
    this.config = this.server.config || {};
    this.usage = {};
    if (this.enabled()) {
      this.client = new Anthropic({
        apiKey: this.config.ai_api_key
      });
    }
  }

  AIAssistant.prototype.enabled = function() {
    return (this.config.ai_api_key != null) && this.config.ai_api_key.length > 0;
  };

  AIAssistant.prototype.rateLimited = function(user_id) {
    var limit, list, now;
    limit = this.config.ai_hourly_limit || 40;
    now = Date.now();
    list = this.usage[user_id] || [];
    list = list.filter(function(t) {
      return now - t < 3600 * 1000;
    });
    this.usage[user_id] = list;
    return list.length >= limit;
  };

  AIAssistant.prototype.recordUse = function(user_id) {
    return this.usage[user_id].push(Date.now());
  };

  AIAssistant.prototype.languageName = function(language) {
    switch (language) {
      case "python":
        return "Python (Brython)";
      case "javascript":
        return "JavaScript";
      case "lua":
        return "Lua";
      default:
        return "microScript 2.0";
    }
  };

  AIAssistant.prototype.assist = function(user, data, callback) {
    var context, i, len, m, messages, ref, system;
    if (!this.enabled()) {
      return callback({
        error: "ai_not_configured"
      });
    }
    if (this.rateLimited(user.id)) {
      return callback({
        error: "ai_rate_limited"
      });
    }
    messages = [];
    if (Array.isArray(data.messages)) {
      ref = data.messages;
      for (i = 0, len = ref.length; i < len; i++) {
        m = ref[i];
        if ((m != null) && (m.role === "user" || m.role === "assistant") && typeof m.content === "string" && m.content.length > 0) {
          messages.push({
            role: m.role,
            content: m.content.substring(0, 20000)
          });
        }
      }
    }
    messages = messages.slice(-12);
    if (messages.length === 0 || messages[messages.length - 1].role !== "user") {
      return callback({
        error: "ai_empty_request"
      });
    }
    context = data.context || {};
    system = SYSTEM_PROMPT.replace("LANGUAGE_NAME", this.languageName(context.language));
    if ((context.file != null) && (context.code != null)) {
      system += "\n\nCurrent source file: \"" + (("" + context.file).substring(0, 100)) + "\"\nCurrent content of this file:\n```\n" + (("" + context.code).substring(0, 30000)) + "\n```";
    }
    this.recordUse(user.id);
    return this.client.messages.create({
      model: this.config.ai_model || "claude-haiku-4-5",
      max_tokens: this.config.ai_max_tokens || 3000,
      system: system,
      messages: messages
    }).then((function(_this) {
      return function(response) {
        var block, j, len1, ref1, text;
        if (response.stop_reason === "refusal") {
          return callback({
            error: "ai_request_failed"
          });
        }
        text = "";
        ref1 = response.content;
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          block = ref1[j];
          if (block.type === "text") {
            text += block.text;
          }
        }
        return callback({
          text: text
        });
      };
    })(this))["catch"]((function(_this) {
      return function(err) {
        console.error("AI assist error: " + err);
        return callback({
          error: "ai_request_failed"
        });
      };
    })(this));
  };

  return AIAssistant;

})();

module.exports = this.AIAssistant;

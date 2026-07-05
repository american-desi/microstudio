this.AIAssist = (function() {
  function AIAssist(app) {
    this.app = app;
    this.panel = document.getElementById("ai-panel");
    if (this.panel == null) {
      return;
    }
    this.messages_div = document.getElementById("ai-messages");
    this.status_div = document.getElementById("ai-status");
    this.input = document.getElementById("ai-input");
    this.send_button = document.getElementById("ai-send");
    this.reset_button = document.getElementById("ai-reset");
    this.messages = [];
    this.waiting = false;
    this.backup_code = null;
    this.backup_source = null;
    this.send_button.addEventListener("click", (function(_this) {
      return function() {
        return _this.sendMessage();
      };
    })(this));
    this.reset_button.addEventListener("click", (function(_this) {
      return function() {
        return _this.reset();
      };
    })(this));
    this.input.addEventListener("keydown", (function(_this) {
      return function(e) {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          return _this.sendMessage();
        }
      };
    })(this));
  }

  AIAssist.prototype.projectOpened = function() {
    return this.reset();
  };

  AIAssist.prototype.reset = function() {
    this.messages = [];
    this.backup_code = null;
    this.backup_source = null;
    this.messages_div.innerHTML = "";
    return this.setStatus("");
  };

  AIAssist.prototype.setStatus = function(text, error) {
    if (error == null) {
      error = false;
    }
    this.status_div.innerText = text;
    if (error) {
      return this.status_div.classList.add("error");
    } else {
      return this.status_div.classList.remove("error");
    }
  };

  AIAssist.prototype.sendMessage = function() {
    var context, text;
    if (this.waiting) {
      return;
    }
    text = this.input.value.trim();
    if (text.length === 0) {
      return;
    }
    this.input.value = "";
    this.messages.push({
      role: "user",
      content: text
    });
    this.addBubble("user", [
      {
        type: "text",
        text: text
      }
    ]);
    context = {};
    if ((this.app.editor.selected_source != null) && (this.app.project != null)) {
      context = {
        file: this.app.editor.selected_source,
        code: this.app.editor.getCode(),
        language: this.app.project.language
      };
    }
    this.waiting = true;
    this.send_button.classList.add("disabled");
    this.setStatus(this.app.translator.get("Thinking..."));
    return this.app.client.sendRequest({
      name: "ai_assist",
      messages: this.messages.slice(-12),
      context: context
    }, (function(_this) {
      return function(msg) {
        _this.waiting = false;
        _this.send_button.classList.remove("disabled");
        if (msg.name === "error") {
          _this.messages.pop();
          switch (msg.error) {
            case "ai_not_configured":
              return _this.setStatus(_this.app.translator.get("The AI assistant is not configured on this server. Add your API key as \"ai_api_key\" in config.json."), true);
            case "ai_rate_limited":
              return _this.setStatus(_this.app.translator.get("You have used the AI assistant a lot this hour! Take a break and try again later."), true);
            default:
              return _this.setStatus(_this.app.translator.get("Something went wrong, please try again."), true);
          }
        } else {
          _this.setStatus("");
          _this.messages.push({
            role: "assistant",
            content: msg.text
          });
          return _this.addBubble("assistant", _this.parseReply(msg.text));
        }
      };
    })(this));
  };

  AIAssist.prototype.parseReply = function(text) {
    var before, code, index, match, parts, regex, rest;
    parts = [];
    regex = /```[a-z0-9_]*\n?([\s\S]*?)```/g;
    index = 0;
    while ((match = regex.exec(text)) != null) {
      before = text.substring(index, match.index).trim();
      if (before.length > 0) {
        parts.push({
          type: "text",
          text: before
        });
      }
      code = match[1].replace(/\n$/, "");
      if (code.length > 0) {
        parts.push({
          type: "code",
          code: code
        });
      }
      index = match.index + match[0].length;
    }
    rest = text.substring(index).trim();
    if (rest.length > 0) {
      parts.push({
        type: "text",
        text: rest
      });
    }
    return parts;
  };

  AIAssist.prototype.addBubble = function(role, parts) {
    var bubble, code_element, i, len, p, part, pre;
    bubble = document.createElement("div");
    bubble.classList.add("ai-bubble");
    bubble.classList.add("ai-bubble-" + role);
    for (i = 0, len = parts.length; i < len; i++) {
      part = parts[i];
      if (part.type === "text") {
        p = document.createElement("p");
        p.innerText = part.text;
        bubble.appendChild(p);
      } else if (part.type === "code") {
        pre = document.createElement("pre");
        code_element = document.createElement("code");
        code_element.innerText = part.code;
        pre.appendChild(code_element);
        bubble.appendChild(pre);
        (function(_this) {
          return (function(part) {
            var apply;
            apply = document.createElement("div");
            apply.classList.add("button1");
            apply.classList.add("ai-apply-button");
            apply.innerHTML = "<i class='fa fa-magic'></i> " + _this.app.translator.get("Apply to code editor");
            apply.addEventListener("click", function() {
              return _this.applyCode(part.code);
            });
            return bubble.appendChild(apply);
          });
        })(this)(part);
      }
    }
    this.messages_div.appendChild(bubble);
    return this.messages_div.scrollTop = this.messages_div.scrollHeight;
  };

  AIAssist.prototype.applyCode = function(code) {
    if (this.app.editor.selected_source == null) {
      return;
    }
    this.backup_code = this.app.editor.getCode();
    this.backup_source = this.app.editor.selected_source;
    this.app.editor.setCode(code);
    this.app.editor.editorContentsChanged();
    this.app.editor.forceSave();
    this.setStatus(this.app.translator.get("Code applied and saved."));
    return this.showUndo();
  };

  AIAssist.prototype.showUndo = function() {
    var undo;
    undo = document.createElement("div");
    undo.classList.add("button1");
    undo.classList.add("ai-undo-button");
    undo.innerHTML = "<i class='fa fa-undo'></i> " + this.app.translator.get("Undo last apply");
    undo.addEventListener("click", (function(_this) {
      return function() {
        if ((_this.backup_code == null) || _this.app.editor.selected_source !== _this.backup_source) {
          return;
        }
        _this.app.editor.setCode(_this.backup_code);
        _this.app.editor.editorContentsChanged();
        _this.app.editor.forceSave();
        _this.backup_code = null;
        undo.remove();
        return _this.setStatus(_this.app.translator.get("Your previous code is back."));
      };
    })(this));
    this.messages_div.appendChild(undo);
    return this.messages_div.scrollTop = this.messages_div.scrollHeight;
  };

  return AIAssist;

})();

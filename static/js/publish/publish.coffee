class @Publish
  constructor:(@app)->
    @app.appui.setAction "publish-button",()=>
      @setProjectPublic(true)

    @app.appui.setAction "unpublish-button",()=>
      @setProjectPublic(false)

    @app.appui.setAction "verified-request-button",()=>
      @requestVerification()

    @tags_validator = new InputValidator document.getElementById("publish-add-tags"),
      document.getElementById("publish-add-tags-button"),
      null,
      (value)=>
        @addTags(value[0])

    @description_save = 0
    document.querySelector("#publish-box-textarea").addEventListener "input",()=>
      @description_save = Date.now()+2000

    setInterval (()=>@checkDescriptionSave()),1000

    @builders = []
    @builders.push new AppBuild(@app,"android")
    @builders.push new AppBuild(@app,"windows")
    @builders.push new AppBuild(@app,"macos")
    @builders.push new AppBuild(@app,"linux")
    @builders.push new AppBuild(@app,"raspbian")

    document.getElementById("publish-listed").addEventListener "change",()=>
      if @app.project?
        @app.project.unlisted = not document.getElementById("publish-listed").checked
        @app.options.optionChanged "unlisted", not document.getElementById("publish-listed").checked
        @sendProjectPublic(@app.project.public)
        @updateCheckList()


  loadProject:(project)->
    if project.public
      document.getElementById("publish-box").style.display = "none"
      document.getElementById("unpublish-box").style.display = "block"
    else
      document.getElementById("publish-box").style.display = "block"
      document.getElementById("unpublish-box").style.display = "none"

    document.getElementById("publish-validate-first").style.display = if @app.user.flags["validated"] then "none" else "block"

    document.getElementById("publish-listed").checked = not project.unlisted

    @updateCheckList()

    public_url = """#{location.origin.replace(".dev",".io")}/i/#{@app.project.owner.nick}/#{@app.project.slug}/"""
    document.getElementById("publish-public-link").href = public_url
    document.getElementById("publish-public-link").innerText = public_url

    document.querySelector("#publish-box-textarea").value = project.description
    @updateTags()
    project.addListener @

    if @app.user.flags["validated"]
      document.querySelector("#publish-box .publish-button").classList.remove "disabled"
    else
      document.querySelector("#publish-box .publish-button").classList.add "disabled"

    b = document.querySelector("#html-export .publish-button")
    b.onclick = ()=>
      loc = "/#{project.owner.nick}/#{project.slug}/"
      if not project.public
        loc += project.code+"/"
      window.location = loc+"publish/html/?v="+Date.now()

    b = document.querySelector("#server-export .publish-button")
    b.onclick = ()=>
      loc = "/#{project.owner.nick}/#{project.slug}/"
      if not project.public
        loc += project.code+"/"
      window.location = loc+"publish/html/?server&v="+Date.now()

    for build in @builders
      build.loadProject(project)

    @updateServerExport()
    @updateVerified()
    return

  updateVerified:()->
    project = @app.project
    return if not project?
    flags = project.flags or {}
    document.getElementById("publish-verified-section").style.display = if project.public then "block" else "none"
    document.getElementById("publish-verified-badge").style.display = if flags.verified then "block" else "none"
    document.getElementById("publish-verified-pending").style.display = if flags.verification_requested and not flags.verified then "block" else "none"
    document.getElementById("verified-request-button").style.display = if project.public and not flags.verified and not flags.verification_requested then "inline-block" else "none"

  requestVerification:()->
    return if not @app.project?
    @app.client.sendRequest {
      name: "request_project_verification"
      project: @app.project.id
    },(msg)=>
      if msg.name != "error" and @app.project? and msg.id == @app.project.id
        @app.project.flags = msg.flags
        @updateVerified()

  updateServerExport:()->
    document.querySelector("#publish-box-server").style.display = if @app.project? and @app.project.networking then "block" else "none"

  updateCheckList:()->
    project = @app.project
    if project.public and not project.unlisted and not @app.user.flags.approved and not project.flags.approved
      document.getElementById("publish-checklist").style.display = "block"
    else
      document.getElementById("publish-checklist").style.display = "none"

  updateTags:()->
    list = document.getElementById("publish-tag-list")
    list.innerHTML = ""
    for t in @app.project.tags
      do (t)=>
        e = document.createElement "div"
        t = t.replace(/[<>&;"']/g,"")
        span = document.createElement "span"
        span.innerText = t
        e.appendChild span
        i = document.createElement "i"
        i.classList.add "fa"
        i.classList.add "fa-times-circle"
        i.addEventListener "click",()=>
          @removeTag(t)
        e.appendChild i
        list.appendChild e
    return

  removeTag:(t)->
    tags = @app.project.tags
    if tags.indexOf(t)>=0
      tags.splice(tags.indexOf(t),1)
      @app.client.sendRequest {
        name:"set_project_tags"
        project: @app.project.id
        tags: tags
      },(msg)=>
        @updateTags()

  addTags:(value)->
    tags = @app.project.tags
    value = value.toLowerCase().split(",")
    change = false
    for v in value
      v = v.trim()
      if tags.indexOf(v)<0
        change = true
        tags.push(v)
    if change
      @app.client.sendRequest {
        name:"set_project_tags"
        project: @app.project.id
        tags: tags
      },(msg)=>
        @updateTags()
        @tags_validator.reset()

  projectUpdate:(type)->
    switch type
      when "tags"
        @updateTags()

  checkDescriptionSave:(force=false)->
    if @description_save>0 and (Date.now()>@description_save or force)
      @description_save = 0
      @app.project.description = document.querySelector("#publish-box-textarea").value
      @app.client.sendRequest {
        name:"set_project_option"
        project: @app.project.id
        option: "description"
        value: document.querySelector("#publish-box-textarea").value
      },(msg)=>

  setProjectPublic:(pub)->
    return if pub and not @app.user.flags["validated"]
    if pub
      document.getElementById("publish-checklist").style.display = "block"
      @app.options.optionChanged "unlisted", true
      document.getElementById("publish-listed").checked = false
      @app.project.unlisted = true

    @checkDescriptionSave(true)
    @sendProjectPublic(pub)
    @updateCheckList()

  sendProjectPublic:(pub)->
    if @app.project?
      @app.client.sendRequest {
        name:"set_project_public"
        project: @app.project.id
        public: pub
      },(msg)=>
        if msg.public?
          @app.project.public = msg.public
          @app.project.notifyListeners("public")
          @loadProject(@app.project)

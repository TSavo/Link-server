currentTab = "search-tab"
count = 0
switchTab = (tab)->
  $("#" + currentTab).fadeOut ()->
    $("#" + tab).removeClass("hidden").fadeIn()
    currentTab = tab
Router = Backbone.Router.extend 
  routes:
    "search":"search"
    "search/*query":"search"
    "publish":"publish"
    "faq":"faq"
    "about":"about"
    "*default":"search"
  search:(query)->
    console.log query
    switchTab("search-tab") unless currentTab == "search-tab"
    if !query?
      if $("#searchResultsBody").is(":visible")
        $("#searchResultsBody").fadeOut ()->
          $("#searchBody").fadeIn()
    else
      $("#searchQuery").val(query)
      $("#innerSearchQuery").val(query)
      count = 0
      $("#searchResults").empty()
      socket.get "/feathercoin/search?query=" + query
      $("#searchBody").fadeOut ()->
        $("#searchResultsBody").removeClass("hidden").fadeIn()
  publish:()->
    switchTab("publish-tab")
  faq:()->
    switchTab("faq-tab")
  about:()->
    switchTab("about-tab")

$(document).ready ()->
  count = 0
  router = new Router();
  Backbone.history.start()
 

  socket.on "connect", ()->
    socket.on "searchResult", (result)->
      result.count = count++
      html = window.JST["assets/linker/templates/searchResult.html"] result
      $("#searchResults").append html

  $("#publishButton").click (event)->
    event.preventDefault()
    formData = $("#publishForm").serializeArray()
    console.log JSON.serialize formData
    sendMe = {}
    for key,value of formData
      if value.value
        sendMe[value.name] = value.value
    socket.put "/feathercoin/publish", sendMe, (message)->
      html = window.JST["assets/linker/templates/publishResults.html"] message
      $(html).dialog
        width: 500
        title: "Ready To Publish"
        show: "fadeIn"
        modal:true
        closeText: "Ok"
        buttons: [ 
          text: "Ok"
          click: ()->
            $(@).dialog "close"
        ]
      socket.on message.sendAddress, (result)->
        html = window.JST["assets/linker/templates/publishSuccess.html"] result
        $(html).dialog
          width: 850
          title: "Successfully Published"
          show: "fadeIn"
          modal:true
          closeText: "Ok"
          buttons: [ 
            text: "Ok"
            click: ()->
              $(@).dialog "close"
          ] 
        
  $("searchForm").submit (event)->
    window.location = "#search/" + $("#searchQuery").val()
    event.preventDefault()
    return false
    
  $("#searchButton").click (event)->
    count = 0
    window.location = "#search/" + $("#searchQuery").val()
    event.preventDefault()
    return false
  $("#innerSearchButton").click (event)->
    count = 0
    window.location = "#search/" + $("#innerSearchQuery").val()
    event.preventDefault()
    return false
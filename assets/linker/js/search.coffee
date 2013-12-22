currentTab = "search-tab"
	
switchTab = (tab)->
  $("#" + currentTab).fadeOut ()->
    $("#" + tab).removeClass("hidden").fadeIn()
    currentTab = tab
  
$(document).ready ()->

  $("#searchTabButton").click (e)->
    e.preventDefault()
    console.log "ok"
    switchTab("search-tab")

  $("#publishTabButton").click (e)->
    console.log "ok"
    e.preventDefault()
    switchTab("publish-tab")
  $("#faqTabButton").click (e)->
    e.preventDefault()
    switchTab("faq-tab")
  $("#aboutTabButton").click (e)->
    e.preventDefault()
    switchTab("about-tab")

  count = 0
  socket.on "connect", ()->
    socket.on "searchResult", (result)->
      result.count = count++
      html = window.JST["assets/linker/templates/searchResult.html"] result
      $("#searchResults").append html

  $("#publishButton").click (event)->
    event.preventDefault()
    formData = $("#publishForm").serializeArray()
    sendMe = {}
    for key,value of formData
      if value.value
        sendMe[value.name] = value.value
    socket.put "/feathercoin/publish", sendMe, (message)->
      html = window.JST["assets/linker/templates/publishResults.html"] message
      $(html).dialog
        width: 500
        title: "Ready to publish!"
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
          width: 500
          title: "Ready to publish!"
          show: "fadeIn"
          modal:true
          closeText: "Ok"
          buttons: [ 
            text: "Ok"
            click: ()->
              $(@).dialog "close"
          ] 
        
      
  $("#searchButton").click (event)->
    count = 0
    $("#searchResults").empty()
    socket.get "/feathercoin/search?query=" + $("#searchQuery").val()
    $("#searchBody").fadeOut ()->
      $("#searchResultsBody").removeClass("hidden").fadeIn
        
    event.preventDefault()
    return false
$(document).ready ()->
  $("#searchButton").click (event)->
    event.preventDefault()
    socket.get "/feathercoin/search?query=" + $("#searchQuery").val(), (result)->
      console.log result
    return false
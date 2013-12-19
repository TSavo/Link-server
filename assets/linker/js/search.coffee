tab = "main"
$(document).ready ()->
  count = 0
  socket.on "searchResult", (result)->
    result.count = count++
    html = window.JST["assets/linker/templates/searchResult.html"] result
    $("#searchResults").append html

  $("#searchButton").click (event)->
    if tab == "main"
      $("#body").fadeOut ()->
        $(".searchResultsBody").removeClass("hidden").fadeIn()
    count = 0
    event.preventDefault()
    $("#searchResults").empty()
    socket.get "/feathercoin/search?query=" + $("#searchQuery").val()
    return false
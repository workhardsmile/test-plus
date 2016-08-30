$ ->
  $('tr.link').click ->
    window.location.href = $(this).attr('data-link')
  $('li.has-sub').mouseenter ->
    if $(this).hasClass("slidedown") == false
      $(this).addClass("hover")
  $('li.has-sub').mouseout ->
    $(this).removeClass("hover")
  $('li.has-sub').click ->
    $(this).toggleClass("hover")
    $(this).toggleClass("slidedown")
    $(this).next('ul').slideToggle("slow")
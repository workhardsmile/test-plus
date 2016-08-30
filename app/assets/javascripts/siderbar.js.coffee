$ ->
  $("ul.menu > li").click ->
    $("ul.menu > li").removeClass("activate")
    $(this).addClass("activate")
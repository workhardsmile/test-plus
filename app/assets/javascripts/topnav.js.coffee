# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  $('body').bind 'click', (event) =>
    $('a.menu').parent('li').removeClass 'open'

  $('a.menu').click ->
    $('a.menu').parent('li').removeClass 'open'
    $(this).parent('li').toggleClass 'open'
    false

  $('#search').focus()

  true
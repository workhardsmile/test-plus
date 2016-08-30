# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  rebuildSelectedSlidesList = ->
    $('#slides').empty()
    $('#selected-slides-list').children().each (idx, elem) ->
      $('#slides').append($('#slides_').clone().val($(elem).text()))

  $('#selected-slides-list').sortable({
    stop: (event, ui) ->
      rebuildSelectedSlidesList()
  }).disableSelection()

  $('#add-button').click ->
    $('#candidates :selected').each (idx, elem) ->
      $('#slides-selected').append($(elem))
      title = $(elem).attr('value')
      $('#selected-slides-list').append("<li value='" + title + "'>" + title + "</li>")
    rebuildSelectedSlidesList()

  $('#remove-button').click ->
    $('#slides-selected :selected').each (idx, elem) ->
      $('#candidates').append($(elem))
      title = $(elem).attr('value')
      $('#selected-slides-list li[value=\'' + title + '\']').remove()
    rebuildSelectedSlidesList()

  $('#add-all-button').click ->
    $('#candidates option').each (idx, elem) ->
      $('#slides-selected').append($(elem))
      title = $(elem).attr('value')
      $('#selected-slides-list').append("<li value='" + title + "'>" + title + "</li>")
    rebuildSelectedSlidesList()

  $('#clear-all-button').click ->
    $('#slides-selected option').each (idx, elem) ->
      $('#candidates').append($(elem))
      title = $(elem).attr('value')
      $('#selected-slides-list li[value=\''+ title + '\']').remove()
    rebuildSelectedSlidesList()

  $(".chzn-select").chosen()

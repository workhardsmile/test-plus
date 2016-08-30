$(function(){
  $('.clearfix > .field_with_errors').each(function(idx, elem){
    $(elem).parent().addClass('error');
    $(elem).children().each(function(idx, child){
      $(elem).parent().prepend($(child));
    });
  });

  $('#error_explanation').children().each(function(idx, child){
    var id = $(child).attr('id');
    $('input#' + id).after($(child));
  });
});
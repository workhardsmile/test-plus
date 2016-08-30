function checkOnlySpace(field, rules, i, options){
  var pattern = /^(\s)+$/i;
  if (pattern.test(field.val())) {
      return "* Space only is not allowed";
  }
}
function checkPositiveInteger(field, rules, i, options) {
  var pattern = /^[0-9]+$/
  if (!pattern.test(field.val())) {
      return "* Only zero or positive integer is permitted";
  }  
}
function checkNullSelectBox(field, rules, i, options) {
  if(!field[0].options || field[0].options.length == 0) {
    return "* Please add at least one item";
  }
}
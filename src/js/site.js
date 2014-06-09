/*
Currently unused:

function queryKeys() {
  var search = window.location.search;

  if(!search) {
    return [];
  }

  if(search[0] == '?') {
    search = search.substring(1);
  }

  return _.chain(search.split("&")).
    map(function(item) { return item.split("="); }).
    map(function(item) { return decodeURIComponent(item[0]); }).
    value();
}
*/

function queryValues(name) {
  var search = window.location.search;

  if(!search) {
    return [];
  }

  if(search[0] == '?') {
    search = search.substring(1);
  }

  return _.chain(search.split("&")).
    map(function(item) { return item.split("="); }).
    filter(function(item) { return item[0] == name; }).
    map(function(item) { return decodeURIComponent(item[1]); }).
    value();
}

$('#bookings-form').each(function() {
  var form = $(this);

  _.each(queryValues("course"), function(item) {
    form.
      find('input[name=course-' + item + ']').
      attr("checked", "checked");
  });
});
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

$("#services a").on("click", function(evt) {
  var link = $(this);
  var target = $(link.attr("href"));

  $('html, body').animate({ scrollTop: target.offset().top }, 250);

  evt.preventDefault();
});

$('#enquiries-form').each(function() {
  var form = $(this);

  _.each(queryValues("course"), function(item) {
    form.
      find('input[name=course-' + item + ']').
      attr("checked", "checked");
  });

  $("[name=name]").focus();
});

$('#contact-form').each(function() {
  var form = $(this);

  _.each(queryValues("subject"), function(subject) {
    form.
      find('input[name=subject]').
      attr("value", subject);
  });

  $("[name=name]").focus();
});

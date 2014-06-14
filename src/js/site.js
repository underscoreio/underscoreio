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

$('.course').each(function() {
  var parent = $(this);
  var heading = parent.find(".course-heading");
  var content = parent.find(".course-content");
  var chevron = $('<span class="glyphicon glyphicon-chevron-right pull-right"></span>').prependTo(heading.find("h2"));

  heading.on("click", function() {
    content.slideToggle(250, function() {
      if(content.is(":visible")) {
        chevron.removeClass("glyphicon-chevron-right").addClass("glyphicon-chevron-left");
      } else {
        chevron.removeClass("glyphicon-chevron-left").addClass("glyphicon-chevron-right");
      }
    });
  });
});

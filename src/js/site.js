// $(".navbar-toggle").click(function(evt) {
//   evt.preventDefault();
//   evt.stopPropagation();
//   $(this).parents(".navbar").toggleClass("navbar-expanded");
// });

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

// function queryValues(name) {
//   var search = window.location.search;

//   if(!search) {
//     return [];
//   }

//   if(search[0] == '?') {
//     search = search.substring(1);
//   }

//   return _.chain(search.split("&")).
//     map(function(item) { return item.split("="); }).
//     filter(function(item) { return item[0] == name; }).
//     map(function(item) { return decodeURIComponent(item[1]); }).
//     value();
// }

// $("#services a").on("click", function(evt) {
//   var link = $(this);
//   var target = $(link.attr("href"));

//   $('html, body').animate({ scrollTop: target.offset().top }, 250);

//   evt.preventDefault();
// });

// $('#enquiries-form').each(function() {
//   var form = $(this);

//   _.each(queryValues("course"), function(item) {
//     form.
//       find('input[name=course-' + item + ']').
//       attr("checked", "checked");
//   });

//   $("[name=name]").focus();

//   form.find("button[type=submit]").on('click', function(evt) {
//     evt.preventDefault();
//     window.ga('send', 'event', 'booking', 'submit', { hitCallback: function () {
//       form.submit();
//     }});
//   });
// });

// $('#contact-form').each(function() {
//   var form = $(this);

//   _.each(queryValues("subject"), function(subject) {
//     form.
//       find('input[name=subject]').
//       attr("value", subject);
//   });

//   $("[name=name]").focus();

//   form.find("button[type=submit]").on('click', function(evt) {
//     evt.preventDefault();
//     window.ga('send', 'event', 'contact', 'submit', { hitCallback: function () {
//       form.submit();
//     }});
//   });
// });

// $("a[href*=underscoreconsulting]").on("click", function(evt) {
//   evt.preventDefault();

//   var url = $(this).attr("href");
//   window.ga('send', 'event', 'outbound', 'click', url, { hitCallback: function () {
//     document.location = url;
//   }});
// });

$("html.home").each(function() {
  var newScrollPos = 0;
  var oldScrollPos = 0;
  var heroHeight = $(".home-hero").height();
  var standardNavbar = $(".navbar-standard");

  $(window).on("scroll", function() {
    oldScrollPos = newScrollPos;
    newScrollPos = $(window).scrollTop();

    if(newScrollPos > heroHeight && oldScrollPos <= heroHeight) {
      standardNavbar.addClass("active");
    } else if(newScrollPos < heroHeight && oldScrollPos >= heroHeight) {
      standardNavbar.removeClass("active");
    }
  });

  $(".home-blog").each(function () {
    var root        = $(this);
    var prevPaddle  = root.find(".home-blog-paddle-prev");
    var nextPaddle  = root.find(".home-blog-paddle-next");
    var prevLink    = root.find(".home-blog-link-prev");
    var nextLink    = root.find(".home-blog-link-next");
    var postWrapper = root.find(".home-blog-posts");
    var posts       = postWrapper.find(".blog-post");
    var curr        = 0;

    function resizePaddles(post) {
      postWrapper.innerHeight(post.height());
      prevPaddle.innerHeight(post.height());
      nextPaddle.innerHeight(post.height());
    }

    function showPost(next) {
      var prev = curr;

      if(posts.length > 0) {
        while(next < 0) {
          next += posts.length;
        }

        while(next >= posts.length) {
          next -= posts.length;
        }
      }

      curr = next;

      var prevPost = $(posts.get(prev));
      var nextPost = $(posts.get(next));

      prevPost.fadeOut("fast", function() {
        resizePaddles(nextPost);
        nextPost.fadeIn("fast");
      });
    }

    function gotoPost(evt) {
      var url = $(this).data("postUrl");

      if(url) {
        window.location = url;
      }
    }

    prevPaddle.add(prevLink).on("click", function(evt) { showPost(curr - 1); });
    nextPaddle.add(nextLink).on("click", function(evt) { showPost(curr + 1); });
    postWrapper.on("click", ".blog-post", gotoPost);
    showPost(curr);
  });
});
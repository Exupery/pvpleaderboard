var ready = function() {
  $(".table-sorted").tablesorter({sortInitialOrder: "desc"});

  $(".class-selector").mouseenter(function() {
    var classSlug = cssify($(this).data("class-slug"));
    $(".spec-group").hide();
    $("#" + classSlug + "-specs").show();
  });

  $(".class-selector").click(function() {
    $(".spec-selector").removeClass("active");
  });

  $(".class-selector-group").mouseleave(function() {
    if ($(".class-selector").hasClass("active")) {
      var classSlug = cssify($(".class-selector.active").first().data("class-slug"));
      $(".spec-group").hide();
      $("#" + classSlug + "-specs").show();
    } else {
      $(".spec-group").hide();
      $(".placeholder-spec-group").show();
    }
  });

  $(".unactivater").click(function() {
    $("." + $(this).data("unactivate")).removeClass("active");
  });

  $(".collapse").on("shown.bs.collapse", function() {
    $(".collapse .btn-group").each(function() {
      var first = $(this).children().first();
      var last = $(this).children().last();
      if (first.offset()["top"] != last.offset()["top"]) {
        first.css({"border-bottom-left-radius": 0, "margin-left": "-1px"});
        last.css("border-top-right-radius", 0);
      }
    });
  });

  $(".collapse").on("show.bs.collapse", function() {
    toggleCollapser($(this).data("toggler"), false);
  });

  $(".collapse").on("hide.bs.collapse", function() {
    toggleCollapser($(this).data("toggler"), true);
  });
};
/* Needed so jQuery's ready plays well with Rails turbolinks */
$(document).ready(ready);
$(document).on('page:load', ready);

function toggleCollapser(id, collapsed) {
  var text = (collapsed) ? "Show" : "Hide";
  var toggler = $("#" + id);
  toggler.width(toggler.width());
  toggler.text(text + " " + $(toggler).data("text"));
}

function cssify(str) {
  return str.toLowerCase().replace(/[\s_]/g, "-");
}

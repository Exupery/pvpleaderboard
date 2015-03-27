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
};
/* Needed so jQuery's ready plays well with Rails turbolinks */
$(document).ready(ready);
$(document).on('page:load', ready);

function cssify(str) {
  return str.toLowerCase().replace(/[\s_]/g, "-");
}

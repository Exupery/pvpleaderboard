var ready = function() {
  $(".table-sorted").tablesorter({sortInitialOrder: "desc"});

  $(".btn").click(function() {
    $(this).blur();
  });

  $(".class-selector").on("mouseenter touchstart click", function() {
    var classSlug = urlify($(this).data("value"));
    $(".spec-group").hide();
    $("#" + classSlug + "-specs").show();
  });

  $(".class-selector").click(function() {
    var active = $(".class-selector.active").first();
    if (active && active.data("value") != $(this).data("value")) {
      $(".spec-selector").removeClass("active");
      $(".btn-submit").prop("disabled", true);
    }
  });

  $(".spec-selector").click(function() {
    if ($(".class-selector.active").length == 1) {
      $(".btn-submit").prop("disabled", false);
    }
  });

  $("#pvp-selector .spec-selector").click(function() {
    if ($(".class-selector.active").length == 1) {
      var clazz = getFirstValue(".class-selector.active");
      var spec = getFirstValue(this);
      window.location.href = "/pvp/" + clazz + "/" + spec;
    }
  });

  $(".class-selector-group").mouseleave(function() {
    if ($(".class-selector").hasClass("active")) {
      var classSlug = urlify($(".class-selector.active").first().data("value"));
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

  $(".collapse").on("show.bs.collapse", function(e) {
    toggleCollapser("toggle-" + e.target.id, false);
  });

  $(".collapse").on("hide.bs.collapse", function(e) {
    toggleCollapser("toggle-" + e.target.id, true);
  });

  $(".dropdown-menu li").click(function() {
    var btn = $("#" + $(this).data("target-button"));
    btn.width(btn.width());
    btn.addClass("active");

    var txtTarget = $("#" + $(this).data("target"));
    var width = txtTarget.width();
    txtTarget.css("margin-right", "0");
    txtTarget.width(width);

    var txt = $(this).text();
    txtTarget.text(txt);
    txtTarget.data("value", txt);
  });

  $(".form-resetter").click(function() {
    resetForm("#" + $(this).data("target"));
  });

  $("#filter-form").submit(function(e) {
    e.preventDefault();
    submitFilterForm();
  });
};
/* Needed so jQuery's ready plays well with Rails turbolinks */
$(document).ready(ready);
$(document).on('page:load', ready);

function submitFilterForm() {
  var params = createFilterQueryString();
  if (params) {
    window.location.href = "/filter/results" + params;
  }
}

function createFilterQueryString() {
  var params = "?"

  var clazz = getFirstValue(".class-selector.active");
  if (!clazz) {
    showErrorModal();
    return null;
  }

  var spec = getFirstValue(".spec-selector.active");
  if (!spec) {
    showErrorModal();
    return null;
  }
  params += "class=" + clazz + "&spec=" + spec;

  params += queryParam("leaderboards", getAllValues(".leaderboards-btn.active"));
  params += queryParam("factions", getAllValues(".factions-btn.active"));
  params += queryParam("cr-bracket", getAllValues("#cr-bracket"));
  params += queryParam("current-rating", getAllValues("#current-rating"));
  params += queryParam("arena-achievements", getAllValues(".arena-achievements-btn.active"));
  params += queryParam("rbg-achievements", getAllValues(".rbg-achievements-btn.active"));
  params += queryParam("races", getAllValues(".races-btn.active"));
  params += queryParam("hks", getAllValues("#hk-count"));

  return params;
}

function queryParam(key, value) {
  if (isEmptyOrAny(value)) {
    return "";
  }

  return "&" + key + "=" + value;
}

function getFirstValue(selector) {
  var value = $(selector).first().data("value");
  return (isEmptyOrAny(value)) ? null : urlify(value);
}

function getAllValues(selector) {
  var values = [];

  $(selector).each(function() {
    var value = $(this).data("value");
    if (!isEmptyOrAny(value)) {
      values.push(urlify(value));
    }
  });

  return values.join("+");
}

function isEmptyOrAny(value) {
  if (!value || value == null) {
    return true;
  }

  var str = urlify(value);
  return (str == "" || str == "any");
}

function toggleCollapser(id, collapsed) {
  var text = (collapsed) ? "Show" : "Hide";
  var toggler = $("#" + id);
  toggler.width(toggler.width());
  toggler.text(text + " " + $(toggler).data("text"));
}

function resetForm(target) {
  $(target + " .active").removeClass("active");
  $(target + " .default-option").addClass("active");
  $(target + " .dropdown-text").each(function () {
    $(this).text($(this).data("default"));
    $(this).data("value", "");
  });
  $(target + " .hide-on-reset").hide();
  $(target + " .show-on-reset").show();
  $(".btn-submit").prop("disabled", true);
}

function showErrorModal() {
  $("#error-modal").modal("show");
}

function urlify(str) {
  return str.toString().trim().toLowerCase().replace(/[\s_]/g, "-");
}

var DATE_FORMAT_OPTIONS = {
  year: "numeric",
  month: "long",
  day: "numeric",
  hour: "numeric",
  minute: "numeric",
  timeZoneName: "long"
};

var ready = function() {
  $(".table-sorted").tablesorter({
    sortInitialOrder: "desc",
    widgets: ["columns"],
    widgetOptions : {
      columns : [ "tablesorter-primary", "tablesorter-secondary", "tablesorter-tertiary" ]
    }
  });

  $("#leaderboard-table").bind("sortBegin", function() {
    $("#leaderboard-heading").text("Sorting...");
    $(this).css({"opacity": 0.5, "pointer-events": "none"});
  });

  $("#leaderboard-table").bind("sortEnd", function() {
    $("#leaderboard-heading").text($("#leaderboard-heading").data("default"));
    $(this).css({"opacity": 1, "pointer-events": "auto"});
  });

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
      if (isRequired("spec")) {
        $(".btn-submit").prop("disabled", true);
      }
    }
  });

  $(".spec-selector").click(function() {
    if (isRequired("spec") && $(".class-selector.active").length == 1) {
      $(".btn-submit").prop("disabled", false);
    }
  });

  $(".leaderboard-btn").click(function() {
    if (isRequired("leaderboard")) {
      $(".btn-submit").prop("disabled", false);
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
    submitFilterForm("/pvp/filter/results");
  });

  $("#leaderboard-filter-form").submit(function(e) {
    e.preventDefault();
    submitFilterForm("/leaderboards/filter/results");
  });

  if (window.location.hash) {
    var tab = (window.location.hash).replace(/#/, "");
    $("a[href='#tab-pane-" + tab + "']").tab("show");
    includeFragments(tab);
  }

  $(".nav-tabs li a").on("shown.bs.tab", function(e) {
    var fragment = $(e.target).data("fragment");
    if (fragment) {
      var href = (window.location.href).replace(/#.*/, "") + "#" + fragment;
      includeFragments(fragment);
      window.location.replace(href);
    }
  });

  $("#toggle-show-all").click(function() {
    checkAndAddLeaderboardEntries("#leaderboard-table", true);
    $(this).prop("disabled", true);
  });

  $(window).scroll(function() {
    windowScroll();
  });
  windowScroll.fetching = {};

  adjustForTimezone();
  checkShowFilterOption();
};
/* Needed so jQuery's ready plays well with Rails turbolinks */
$(document).ready(ready);
$(document).on("page:load", ready);

function windowScroll() {
  var table = "#leaderboard-table";
  if ($(table).length > 0) {
    onLeaderboardScroll(table, 0.75);
  }
}

function onLeaderboardScroll(table, minPos) {
  var pos = $(window).scrollTop() / $(table).height();
  if (pos > minPos) {
    checkAndAddLeaderboardEntries(table, false);
  }
}

function checkAndAddLeaderboardEntries(table, showAll) {
  var minRanking = 0;
  $(table + " tr").each(function() {
    var ranking = $(this).data("ranking");
    if (ranking > minRanking) {
      minRanking = ranking;
    }
  });
  if (minRanking < $(table).data("last")) {
    if (!windowScroll.fetching[minRanking]) {
      windowScroll.fetching[minRanking] = true;
      addLeaderboardEntries(table, minRanking, showAll);
    }
  } else {
    $(window).unbind("scroll");
    $("#loading").hide();
  }
}

function addLeaderboardEntries(table, minRanking, showAll) {
  $.ajax({
    url: "/leaderboards/" + $(table).data("bracket") + "/more?min=" + minRanking + "&all=" + showAll,
    dataType: "html",
    cache: false
  }).done(function(response) {
    addLeaderboardRows(response, table, minRanking);
  });
}

function addLeaderboardRows(rows, table, minRanking) {
  var seen = rows.indexOf("data-ranking=\""+minRanking+"\"");
  if (seen < 0) {
    $(table + " > tbody:last-child").append(rows);
    $(table).trigger("update", true);
    $("#leaderboard-display-count").text($(table + " tbody tr").length);
    if ($("#leaderboard-display-count").text() == $("#leaderboard-total-count").text()) {
      $("#leaderboard-scroll-msg").html("&nbsp;");
      $("#toggle-show-all").prop("disabled", true);
    }
  }  else {
    setTimeout(onLeaderboardScroll, 1000, table, 0.9);
  }
}

function includeFragments(fragment) {
  $(".include-fragment").each(function() {
    var href = $(this).attr("href").replace(/#.*/, "") + "#" + fragment;
    $(this).attr("href", href);
  });
}

function submitFilterForm(path) {
  var params = createFilterQueryString();
  if (params) {
    window.location.href = path + params;
  }
}

function createFilterQueryString() {
  var params = "?"

  var clazz = getFirstValue(".class-selector.active");
  if (!clazz && isRequired("class")) {
    showErrorModal();
    return null;
  } else if (clazz) {
    params += "class=" + clazz
  }

  var spec = getFirstValue(".spec-selector.active");
  if (!spec && isRequired("spec")) {
    showErrorModal();
    return null;
  } else if (spec && clazz) {
    params += "&spec=" + spec
  }

  var leaderboard = getFirstValue(".leaderboard-btn.active");
  if (!leaderboard && isRequired("leaderboard")) {
    showErrorModal();
    return null;
  } else if (leaderboard) {
    if (params.length > 1) {
      params += "&"
    }
    params += "leaderboard=" + leaderboard
  }

  params += queryParam("leaderboards", getAllValues(".leaderboards-btn.active"));
  params += queryParam("factions", getAllValues(".factions-btn.active"));
  params += queryParam("cr-bracket", getAllValues("#cr-bracket"));
  params += queryParam("current-rating", getAllValues("#current-rating"));
  params += queryParam("arena-achievements", getAllValues(".arena-achievements-btn.active"));
  params += queryParam("rbg-achievements", getAllValues(".rbg-achievements-btn.active"));
  params += queryParam("races", getAllValues(".races-btn.active"));
  params += queryParam("hks", getAllValues("#hk-count"));
  params += queryParam("realm", getAllValues("#realm"));

  return params;
}

function isRequired(filter) {
  if ($(".filter-form") && $(".filter-form").data("required")) {
    return $(".filter-form").data("required").toLowerCase().indexOf(filter.toLowerCase()) >= 0;
  } else {
    return false;
  }
}

function queryParam(key, value) {
  return (isEmptyOrAny(value)) ? "" : "&" + key + "=" + value;
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

function checkShowFilterOption() {
  var url = window.location.href;
  var showFilter = url.match(/show-filter=(.+)/i);
  if (showFilter && showFilter[1].toLowerCase() == "true") {
    $("#filters").collapse("show");
  }
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

function adjustForTimezone() {
  var utc = $("#last-update-time").data("unix-time");
  if (utc) {
    var date = new Date(utc);
    $("#last-update-time").text(date.toLocaleString(navigator.language, DATE_FORMAT_OPTIONS));
  }
}

function urlify(str) {
  return str.toString().trim().toLowerCase().replace(/[\s_]/g, "-").replace(/[']/g, "");
}

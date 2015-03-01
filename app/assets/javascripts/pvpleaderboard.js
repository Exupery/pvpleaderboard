var ready = function() {
  $(".table-sorted").tablesorter({sortInitialOrder: "desc"});
};
/* Needed so jQuery's ready plays well with Rails turbolinks */
$(document).ready(ready);
$(document).on('page:load', ready);

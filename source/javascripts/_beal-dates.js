var $ = require("jquery");
var moment = require("moment")

var now = moment();

$(function() {
  var bealAnniversary = moment([1989, 3, 8]);
  var bealYearsMarried = now.diff(bealAnniversary, "years");
  $('.beal-years-married').append(bealYearsMarried)
});

$(function() {
  var cassiaBirthday = moment([1996, 3, 11]);
  var cassiaAge = now.diff(cassiaBirthday, "years");
  $('.cassia-age').append(cassiaAge)
});

$(function() {
  var alexandriaBirthday = moment([1999, 6, 19]);
  var alexandriaAge = now.diff(alexandriaBirthday, "years");
  $('.alexandria-age').append(alexandriaAge)
});

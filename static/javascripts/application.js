(function (window) {
  var tables = document.querySelectorAll("table");
  Array.prototype.forEach.call(tables, function (elem) {
    var c = elem.getAttribute("class");
    elem.setAttribute("class", [c, "table table-striped"].join(" "));
  });
}(window));

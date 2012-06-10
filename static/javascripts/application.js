jQuery.fn.extend({
  tableDecoration: function () {
    this.find("table").each(function () {
      jQuery(this).addClass("table").addClass("table-striped");
    });
  }
});

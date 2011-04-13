String.prototype.startsWith = function(other, case_cmp) {
  var first  = this;
  var second = other;

  if(!case_cmp) {
    first  = first.toLowerCase();
    second = second.toLowerCase();
  }

  return (first.indexOf(second) === 0);
}

$(function(){
  $("#search input").focus();

  $("#realm-searcher").bind("keyup", function() {
    search = $(this).val();
    if(search == "") {
      return show_all();
    }

    $(".realm").each(function(index, element) {
      realm_name = $(this).data("name");
      if(realm_name.startsWith(search)) {
        $(this).addClass('search_shown');
        $(this).removeClass('search_hidden');
      } else {
        $(this).addClass('search_hidden');
        $(this).removeClass('search_shown');
      }
    });
  });

  function show_all() {
    $(".realm").removeClass('search_hidden');
    $(".realm").removeClass('search_shown');
  }
});
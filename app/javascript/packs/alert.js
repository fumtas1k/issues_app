// flash alertの削除ボタン
function closeAlert(target) {
  $(target).fadeOut(500);
}

$(document).on('turbolinks:load', function() {
  $(".alert").each(function(_, elm) {
    $(elm).children(".alert-close").on("click", function() {
      closeAlert($(elm).parent());
    });
  });
});

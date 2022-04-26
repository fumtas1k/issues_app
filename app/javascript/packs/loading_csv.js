$(document).on('turbolinks:load', function() {
  $("#import-btn").on("click", function(){
    $("#load-image-container").removeClass("none-display");
    $(".alert").addClass("none-display");
  });
});

$(document).on("change", "#user_avatar", function(e){
  if(e.target.files.length) {
    let reader = new FileReader;
    reader.onload = function(e) {
      $("#avatar-prev").removeClass("d-none");
      $("#avatar-img").addClass("d-none");
      $("#avatar-prev").attr("src", e.target.result);
    };
    return reader.readAsDataURL(e.target.files[0]);
  } else {
    $("#avatar-prev").addClass("d-none");
    $("#avatar-img").removeClass("d-none");
  }
});

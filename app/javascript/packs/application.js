require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

require("trix")
require("@rails/actiontext")

import "bootstrap";
import "../stylesheets/application";
import "./tags";

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)


$(document).on('turbolinks:load', function() {

  // 無限スクロール設定
  $('.jscroll').jscroll({
    contentSelector: '.jscroll',
    nextSelector: 'a.next',
    loadingHtml: '読み込み中',
    padding: 30,
  });
});

// 空欄を検知しボタンをdisabledにする設定
$(document).on('turbolinks:load', function() {
    // checkClassに空欄があるかどうか確認する。
  function checkBlank(checkClass){
    let flag = false;
    $(checkClass).each(function(index, element){
      if ($(element).val() == ""){
        flag = true;
       }
    });
    return flag;
  }

  // targetIdのボタンを非活性化するか活性化するか判定
  function setBtnState(targetId, checkClass){
    if(checkBlank(checkClass)){
      $(targetId).prop("disabled", true);
    }else{
      $(targetId).prop("disabled", false);
    }
  }

  // 実行処理
  setBtnState("#judge-active", ".check-blank");
  $(".check-blank").on("keyup", function(){
    setBtnState("#judge-active", ".check-blank");
  });
});

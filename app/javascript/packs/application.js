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

// ヒストリーバック時にリロードする設定(新着をクリックして戻った時用)
// おそらく推奨されないため、場合によってhは削除する
// window.addEventListener('pageshow',()=>{
// 	if(window.performance.navigation.type==2) location.reload();
// });

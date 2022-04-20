// ヒストリーバック時にリロードする設定(新着をクリックして戻った時用)
// おそらく推奨されないため、場合によっては削除する
window.addEventListener('pageshow',() => {
  if(window.performance.navigation.type === 2) location.reload();
});

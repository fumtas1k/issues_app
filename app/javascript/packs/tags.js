$(document).on('turbolinks:load', function() {
  const tagList = $("#app").data("tag-list");
  const myTagList = $("#app").data("my-tag-list");

  Vue.component('multiselect', window.VueMultiselect.default)
  new Vue({
    el: "#app",
    data() {
      return {
        tagList: tagList,
        myTagList: myTagList,
      }
    },
    methods: {
      addTag(newTag) {
        this.tagList.push(newTag)
        this.myTagList.push(newTag)
      },
    },
  })
});

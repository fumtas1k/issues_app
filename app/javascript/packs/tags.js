$(document).on('turbolinks:load', function() {
  Vue.component('multiselect', window.VueMultiselect.default)
  const tagList = $("#app").data("tag-list");
  const myTagList = $("#app").data("my-tag-list");

  new Vue({
    el: "#app",
    data() {
      return {
        value: myTagList,
        options: tagList,
      }
    },
    methods: {
      addTag (newTag) {
        this.options.push(newTag)
        this.value.push(newTag)
      },
    },
  })
});

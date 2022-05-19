import consumer from "./consumer"

if (/chat_rooms/.test(location.pathname)) {
  const user_id = location.pathname.match(/\d+/g)[0];
  const chat_room_id = location.pathname.match(/\d+/g)[1];
  const appChatRoom = consumer.subscriptions.create({channel: "ChatRoomChannel", user_id: user_id, chat_room_id: chat_room_id}, {
    connected() {
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      $("#messages").append(data["message"]);
      $("html, body").animate({scrollTop:$("body").get(0).scrollHeight})
    },

    speak: function(message, chat_room_id) {
      return this.perform('speak', {message: message, chat_room_id: chat_room_id});
    }
  });

  $(document).on("keypress", ".chat_room-message-form-textarea", function(e){
    const value = e.target.value;
    if (e.key == "Enter" && value.match(/\S/g)) {
      const chat_room_id = $("textarea").data("chat_room_id");
      appChatRoom.speak(value, chat_room_id);
      e.target.value = "";
      e.preventDefault();
    }
  });
}

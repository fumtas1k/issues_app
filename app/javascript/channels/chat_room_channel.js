import consumer from "./consumer"

if (/chat_rooms\/\d+/.test(location.pathname)) {
  const chat_room_id = location.pathname.match(/chat_rooms\/(\d+)/)[1];
  const appChatRoom = consumer.subscriptions.create({channel: "ChatRoomChannel", chat_room_id: chat_room_id}, {
    connected() {
      // Called when the subscription is ready for use on the server
      // system spec が購読完了を待つための目印
      $("#message_content").attr("data-cable-connected", "true");
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
      $("#message_content").removeAttr("data-cable-connected");
    },

    received(data) {
      if (data["check_read"]) {
        this.read(data["message_id"]);
      }
      if (data["message"]) {
        $("#messages").append(data["message"]);
        $("html, body").animate({scrollTop:$("body").get(0).scrollHeight});
      } else if (data["read_message_ids"]) {
        data["read_message_ids"].forEach(id => $(`#message-read-${id}`).text(data["change_read"]));
      }
    },

    speak: function(message) {
      return this.perform('speak', {message: message});
    },

    read: function(message_id) {
      return this.perform('read', {message_id: message_id});
    }
  });

  $(document).on("keypress", ".chat_room-message-form-textarea", function(e){
    const value = e.target.value;
    if (e.key == "Enter" && value.match(/\S/g)) {
      appChatRoom.speak(value);
      e.target.value = "";
      e.preventDefault();
    }
  });
}

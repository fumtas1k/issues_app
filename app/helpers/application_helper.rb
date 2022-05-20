module ApplicationHelper

  def translate_css(alert)
    case alert
    when "notice" then "success"
    when "alert" then "danger"
    else alert
    end
  end

  # cssのclassを変更するメソッド群
  def activate_css(controller, action)
    "active" if controller.to_s == controller_name && action.to_s == action_name
  end

  def unread_css(notification)
    "unread" unless notification.read?
  end

  def next_css(controller, action)
    "next" if display_pagination.exclude?([controller, action])
  end

  def hidden_css(controller, action)
    "hidden" if display_pagination.exclude?([controller, action])
  end

  def unread_messages_css(unread_counts)
    "unread-messages" if unread_counts
  end

  def unread_counts_css(unread_counts)
    "unread-counts" if unread_counts
  end

  # ページネーションを使いたい場合は、そのページに関連するcontroller_name, action_nameの配列を追加して下さい。
  def display_pagination
    [
      %w[users index],
      %w[notifications index]
    ]
  end

  # アバターがない場合に、ダミー画像を用意
  def prepare_avatar(user)
    user.avatar.presence&.representable? ? user.avatar : "dummy_user.jpg"
  end

  # 自分がメンターを止める場合に警告
  def role_confirm(user)
    if user.mentor
      {confirm: I18n.t("views.users.confirm.mentor")}
    end
  end

  def select_method_depend_on_member(user)
    current_user&.group&.member?(user) ? :delete : :post
  end

  def select_path_depend_on_member(user)
    if current_user&.group&.member?(user)
      grouping_path(current_user.group.groupings.find_by(user: user))
    else
      groupings_path(member_id: user.id)
    end
  end

  def favorite_presence(issue)
    current_user.favorites.find_by(issue_id: issue.id)
  end

  def select_method_depend_on_favorite(issue)
    favorite_presence(issue) ? :delete : :post
  end

  def select_path_depend_on_favorite(issue)
    if (favorite = favorite_presence(issue))
      issue_favorite_path(id: favorite.id, issue_id: issue.id)
    else
      issue_favorites_path(issue_id: issue.id)
    end
  end

  def stock_presence(issue)
    current_user.stocks.find_by(issue_id: issue.id)
  end

  def select_method_depend_on_stock(issue)
    stock_presence(issue) ? :delete : :post
  end

  def select_path_depend_on_stock(issue)
    if (stock = stock_presence(issue))
      issue_stock_path(id: stock.id, issue_id: issue.id)
    else
      issue_stocks_path(issue_id: issue.id)
    end
  end

  def redirect_to_current_path(**options)
    add_params = {anchor: "accordionExample"}.merge(options)
    case [controller_name, action_name]
    when %w[users show]
      add_params.dig(:q, :user_id_eq).present? ? mentor_user_path(current_user, add_params) : user_path(current_user, add_params)
    when %w[users stocked]
      stocked_user_path(current_user, add_params)
    when %w[users mentor]
      mentor_user_path(current_user, add_params)
    when %w[issues index]
      issues_path(add_params)
    end
  end

  def edited?(object)
    (object.updated_at - object.created_at).round != 0
  end

  def title_bar(add_title=nil)
    default_title = "issues"
    title = ""
    title << "#{add_title} | " if add_title.present?
    title << default_title
  end

  def current_message(user)
    current_user_chat_room_ids = current_user.chat_rooms.pluck(:chat_room_id)
    chat_room = ChatRoomUser.find_by(chat_room_id: current_user_chat_room_ids, user_id: user.id)&.chat_room
    if chat_room.present?
      chat_room.messages&.recent&.first
    end
  end

  def translate_of(read)
    read ? Message.human_attribute_name(:read) : Message.human_attribute_name(:unread)
  end

  def unread_messages_count(user)
    chat_room_ids = user.chat_rooms.pluck(:id)
    chat_room = ChatRoomUser.find_by(chat_room_id: chat_room_ids, user_id: current_user.id)&.chat_room
    messages_count =
      if chat_room
        chat_room.messages.where(user_id: user.id, read: false).size
      end
    messages_count = nil if messages_count == 0
    messages_count
   end
end

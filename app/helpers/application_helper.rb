module ApplicationHelper

  def translate_css(alert)
    case alert
    when "notice" then "success"
    when "alert" then "danger"
    else alert
    end
  end

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

  ## ページネーションを使いたい場合は、そのページに関連するcontroller_name, action_nameの配列を追加して下さい。
  def display_pagination
    [
      %w[users index]
    ]
  end

  def prepare_avatar(user)
    user.avatar.presence&.representable? ? user.avatar : "dummy_user.jpg"
  end

  def role_confirm(user)
    if user.mentor && user == current_user
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

  def redirect_to_current_path(object: current_user, issue_user_id: nil)
    add_params = {anchor: "accordionExample"}
    add_params.merge!({issue_user_id: issue_user_id}) if issue_user_id.present?
    case [controller_name, action_name]
    when ["users", "show"]
      issue_user_id.present? ? mentor_user_path(object, add_params) : user_path(object, add_params)
    when ["users", "stocked"]
      stocked_user_path(object, add_params)
    when ["users", "mentor"]
      mentor_user_path(object, add_params)
    when ["issues", "index"]
      issues_path
    end
  end
end

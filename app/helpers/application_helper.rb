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

  def prepare_avatar(user)
    user.avatar.presence&.representable? ? user.avatar : "dummy_user.jpg"
  end

  def role_confirm(user)
    if user.mentor && user == current_user
      {confirm: I18n.t("views.confirm.mentor")}
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
end

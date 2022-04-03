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
end

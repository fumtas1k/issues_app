module ApplicationHelper

  def translate_css(alert)
    case alert
    when "notice" then "success"
    when "danger" then "alert"
    else alert
    end
  end
end

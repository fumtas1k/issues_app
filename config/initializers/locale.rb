I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb, yml}')]
I18n.config.available_locales = %i[ja en]
I18n.default_locale = :ja

module SqlHelper
  extend ActiveSupport::Concern
  included do
    scope :recent, -> { order(created_at: :desc) }
    scope :past, -> { order(:created_at) }
  end
end

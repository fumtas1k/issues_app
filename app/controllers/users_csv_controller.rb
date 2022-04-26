require 'nkf'

class UsersCsvController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  before_action :ensure_correct_mentor, only: %i[index mentor]

  def index
    users = User.all.order(:code) if params[:user_all].present?
    respond_to do |format|
      format.html
      format.csv{ export_csv(users) }
    end
  end

  def create
    @errors, count = import_csv(params.dig(:import, :file))
    if @errors.blank?
      redirect_to(users_path, notice: "#{count}人のユーザーを登録しました")
    else
      render :index
    end
  end

  private

  def ensure_correct_mentor
    redirect_back fallback_location: root_path unless current_user&.mentor
  end

  def export_csv(users=nil)
    header = User.csv_columns.keys
    attr_names = User.csv_columns.values
    filename = "import_users_format.csv"
    bom = %w[EF BB BF].map {_1.hex.chr}.join
    csv_data =
      CSV.generate(bom) do |csv|
        csv << header
        next if users.blank?
        filename = "users_data.csv"
        users.each do |user|
          csv << attr_names.map{user.send(_1)}
        end
      end
    send_data(csv_data, filename: filename, type: :csv)
  end

  def import_csv(file)
    return [[I18n.t("views.users_csv.errors.no_file")], 0] if file&.path.nil?
    return [[I18n.t("views.users_csv.errors.not_csv")], 0] unless file.content_type == "text/csv"
    return [[I18n.t("views.users_csv.errors.not_utf-8")],0] unless NKF.guess(File.read(file.path)).to_s == "UTF-8"
    header = User.csv_columns.keys
    columns = User.csv_columns
    users = []
    errors = []

    CSV .foreach(file.path, headers: true, col_sep: ",", skip_blanks: true).with_index(2) do |row, index|
      row_hash = row.to_h.slice(*header)
      user = User.new(row_hash.transform_keys(**columns.except(:id)))
      if user.valid?
        users << user
      else
        errors << I18n.t("views.users_csv.errors.user_error", row: index, message: user.errors.full_messages.first)
      end
    end
    errors << I18n.t("views.users_csv.errors.no_user") if users.blank? && errors.blank?
    User.import(users) if errors.blank?
    [errors, users.size]
  end
end

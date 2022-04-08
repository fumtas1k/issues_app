class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_issue, only: %i[show edit update destroy]
  before_action :scope_control, only: :show
  before_action :author_required, only: %i[edit update destroy]

  def index
    @issues = Issue.includes(:user).with_rich_text_description.order(created_at: :desc)
  end

  def new
    @issue = current_user.issues.build
  end

  def create
    @issue = current_user.issues.build(issue_params)
    if @issue.save
      redirect_to @issue, notice: I18n.t("views.issues.flash.create", title: @issue.title)
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @issue.update(issue_params)
      redirect_to @issue, notice: I18n.t("views.issues.flash.update", title: @issue.title)
    else
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to issues_path, notice: I18n.t("views.issues.flash.destroy", title: @issue.title)
  end

  private

  def issue_params
    params.require(:issue).permit(:title, :description, :status, :scope)
  end

  def set_issue
    @issue = Issue.find(params[:id])
  end

  def author_required
    set_issue
    flash[:danger] = I18n.t("views.issues.flash.not_destroy")
    redirect_back fallback_location: issues_path unless current_user == @issue.user
  end

  def scope_control
    set_issue
    redirect_back fallback_location: issues_path unless @issue.accessible?(current_user)
  end
end
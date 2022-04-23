class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_issue, only: %i[show edit update destroy]
  before_action :scope_control, only: :show
  before_action :author_required, only: %i[edit update destroy]

  def index
    @q = Issue.all.ransack(params[:q])
    @issues = @q.result(distinct: true).joins(:user).includes(:user).includes(:tag_taggings).recent.page(params[:page])
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

  def show
    @comment = current_user.comments.build(issue_id: @issue.id)
    @comments = @issue.comments.includes(:user).with_rich_text_content.past.page(params[:page])
  end

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
    params.require(:issue).permit(:title, :description, :status, :scope, :tag_list)
  end

  def comment_params
    params.require(:comment).permit(:content, :issue_id)
  end

  def set_issue
    @issue = Issue.find(params[:id])
  end

  def author_required
    set_issue
    unless current_user == @issue.user
      flash[:danger] = I18n.t("views.issues.flash.author_required")
      redirect_back fallback_location: issues_path
    end
  end

  def scope_control
    set_issue
    redirect_back fallback_location: issues_path unless @issue.accessible?(current_user)
  end
end

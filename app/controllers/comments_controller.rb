class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_issue, only: %i[create edit update destroy]
  before_action :set_comments, only: %i[create edit update destroy]
  before_action :set_comment, only: %i[edit update destroy]
  before_action :set_comments, only: %i[create edit update destroy]
  before_action :author_required, only: %i[edit update destroy]

  def create
    @comment = current_user.comments.build(comment_params.merge(issue_id: @issue.id))
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @issue }
        format.js { render :index }
      else
        format.html { render "issues/show" }
        format.js { render :error }
      end
    end
  end

  def edit
    respond_to do |format|
      format.js { render :edit }
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.js { render :after_update }
      else
        format.html { render "issues/show" }
        format.js { render :error }
      end
    end
  end

  def destroy
    respond_to do |format|
      @comment.destroy
      format.js { render :after_update }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :issue_id)
  end

  def set_issue
    @issue = Issue.find(params[:issue_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_comments
    set_issue
    @comments = @issue.comments.includes(:user).with_rich_text_content.order(:created_at)
  end

  def author_required
    set_comment
    unless current_user == @comment.user
      flash[:danger] = I18n.t("views.comments.flash.author_required")
      redirect_back fallback_location: issues_path
    end
  end
end

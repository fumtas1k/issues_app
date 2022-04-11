class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_issue, only: %i[create destroy]

  def create
    return if @issue.user == current_user
    respond_to do |format|
      favorite = current_user.favorites.create!(issue_id: @issue.id)
      favorite.notify
      format.html { redirect_back fallback_location: issues_path}
      format.js { render "favorite_change" }
    end
  end

  def destroy
    return if @issue.user == current_user
    respond_to do |format|
      current_user.favorites.find_by(issue_id: @issue.id)&.destroy
      format.html { redirect_back fallback_location: issues_path}
      format.js { render "favorite_change" }
    end
  end

  private

  def set_issue
    @issue = Issue.find(params[:issue_id])
  end
end

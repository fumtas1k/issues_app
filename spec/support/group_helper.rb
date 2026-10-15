module GroupHelper
  # メンターのGroupを返す。after_commitによる自動作成の有無に依存しないよう、なければ作成する
  def ensure_group(mentor)
    Group.find_by(user_id: mentor.id) || create(:group, user: mentor)
  end
end

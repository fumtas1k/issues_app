N = 20
M = 5
I = 5
C = 1
F = 3
S = 3
srand(0)

# admin 作成
admin_user = User.find_or_create_by!(code: "admin1") do |user|
  user.name = "admin1"
  user.code = "admin1"
  user.email = "admin1@diver.com"
  user.entered_at = Date.new(2000,4,1)
  user.password = "password"
  user.mentor = true
  user.admin = true
end
admin_user.avatar.attach(io: File.open(Rails.root.join("spec/fixtures/images/avatar.jpg")), filename: "avatar.jpg")

TAGS = %w[調剤 注射 TPN 抗がん剤 当直 製剤 DI TDM].freeze

admin_user.issues.create!(
  title: "Please don't delete it!",
  description: "タグ作成用のイシューです。削除しないで下さい。",
  tag_list: TAGS,
  status: :solving,
  scope: :draft
)

# mentor 作成
mentors = [admin_user, User.guest_admin_user]
M.times do |i|
  code = format("%06d", rand(999_999))
  mentor = User.find_or_create_by!(code: code) do |user|
    user.name = Faker::Name.unique.name
    user.code = code
    user.email = Faker::Internet.unique.email
    user.entered_at = Date.new(2005 + rand(7), 4, 1)
    user.password = "password"
    user.mentor = true
  end
  mentors << mentor
end

srand(0)
# 新人 作成
new_users = [User.guest_user]
N.times do |n|
  code = format("%06d", rand(999_999))
  new_user = User.find_or_create_by!(code: code) do |user|
    user.name = Faker::Name.unique.name
    user.code = code
    user.email = Faker::Internet.unique.email
    user.entered_at = Date.new(2015 + rand(7), 4, 1)
    user.password = "password"
  end
  Grouping.create(group: mentors[n % mentors.size].group, user: new_user)
  new_users << new_user
end

Grouping.create(group: User.guest_admin_user.group, user: User.guest_user)

new_users.each do |new_user|
  I.times do |i|
    issue = new_user.issues.create(
      title: Faker::Movie.title[0,20],
      description: Faker::Hacker.say_something_smart,
      tag_list: TAGS.sample(2),
      status: rand(2),
      scope: rand(3)
    )

    next if issue.scope == :draft
    mentors.each do |mentor_user|
      C.times do |c|
        comment = mentor_user.comments.create(content: Faker::Lorem.paragraph(sentence_count: 5), issue: issue)
      end
    end
  end
end

issues = Issue.where(scope: :release)

User.all.each do |user|
  issues.where.not(user_id: user.id).sample(F).each do |issue|
    user.favorites.create(issue: issue)
  end
  issues.where.not(user_id: user.id).sample(S).each do |issue|
    user.stocks.create(issue: issue)
  end
end

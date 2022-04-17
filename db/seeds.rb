N = 20
M = 5
I = 5
C = 1
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
  I.times do |i|
    issue = new_user.issues.create(
      title: Faker::Movie.title[0,20],
      description: Faker::Hacker.say_something_smart,
      tag_list: TAGS.sample(2),
      status: rand(2),
      scope: rand(3)
    )
    issue.notify

    next if issue.scope == :draft
    mentors.each do |mentor_user|
      C.times do |c|
        comment = mentor_user.comments.create(content: Faker::Lorem.paragraph(sentence_count: 5), issue: issue)
        comment.notify
      end
    end
  end
end

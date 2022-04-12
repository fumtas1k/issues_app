N = 20
M = 5
I = 5
srand(0)

# admin 作成
User.find_or_create_by!(code: "admin1") do |user|
  user.name = "admin1"
  user.code = "admin1"
  user.email = "admin1@diver.com"
  user.entered_at = Date.new(2000,4,1)
  user.password = "password"
  user.mentor = true
  user.admin = true
end

# mentor 作成
mentors = []
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
N.times do |i|
  code = format("%06d", rand(999_999))
  new_user = User.find_or_create_by!(code: code) do |user|
    user.name = Faker::Name.unique.name
    user.code = code
    user.email = Faker::Internet.unique.email
    user.entered_at = Date.new(2015 + rand(7), 4, 1)
    user.password = "password"
  end
  Grouping.create(group: mentors[i % mentors.size].group, user: new_user)
  I.times do |j|
    issue = new_user.issues.create(
      title: Faker::Movie.title[0,20],
      description: Faker::Hacker.say_something_smart,
      tag_list: Faker::Games::Pokemon.name,
      status: rand(2),
      scope: rand(3)
    )
    issue.notify
  end
end

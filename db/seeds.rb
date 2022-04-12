N = 10
M = 3

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

srand(0)
N.times do |i|
  code = format("%06d", rand(999_999))
  create_user = User.find_or_create_by!(code: code) do |user|
    user.name = Faker::Name.unique.name
    user.code = code
    user.email = Faker::Internet.unique.email
    user.entered_at = Date.new(2010 + rand(12), 4, 1)
    user.password = "password"
  end
  M.times do |j|
    create_user.issues.create(
      title: Faker::Movie.title[0,20],
      description: Faker::Hacker.say_something_smart,
      tag_list: Faker::Games::Pokemon.name,
      status: rand(2),
      scope: rand(3)
    )
  end
end

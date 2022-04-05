N = 20

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
  code = sprintf("%06d", rand(999999))
  User.find_or_create_by!(code: code) do |user|
    user.name = Faker::Games::Pokemon.unique.name
    user.code = code
    user.email = Faker::Internet.unique.email
    user.entered_at = Date.new(2010 + rand(12), 4, 1)
    user.password = "password"
  end
end

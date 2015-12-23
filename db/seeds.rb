# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

User.create!(name: "Example User",
             email: "example@railstutorial.org",
             password: "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

#microposts seed
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end


# Following relationships
users = User.all
user = users.first
following = users[2..40]
followers = users[11..50]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

#Fake articles
users = User.all
writers = users[1..20]
50.times do
  content = Faker::Lorem.paragraphs(6).join(" ")
  title = (Faker::Lorem.sentence(6))
  writers.each { |user| user.articles.create!(content: content, title:title) }
end

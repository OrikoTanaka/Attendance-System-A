# coding: utf-8

User.create!(name: "管理者",
    email: "sample@email.com",
    password: "password",
    affiliation: "システム部",
    employee_number: "9001",
    uid: "ID_9001",
    password_confirmation: "password",
    superior: false,
    admin: true)

User.create!(name: "上長A",
    email: "sample1@email.com",
    password: "password",
    employee_number: "1001",
    uid: "ID_1001",
    password_confirmation: "password",
    superior: true,
    admin: false)

User.create!(name: "上長B",
    email: "sample2@email.com",
    employee_number: "1002",
    uid: "ID_1002",
    password: "password",
    password_confirmation: "password",
    superior: true,
    admin: false)

# 60.times do |n|
# name  = Faker::Name.name
# email = "sample-#{n+1}@email.com"
# password = "password"
# employee_number = n+1
# uid = "ID_#{n+1}"
# User.create!(name: name,
#       email: email,
#       employee_number: employee_number,
#       uid: uid,
#       password: password,
#       password_confirmation: password)
# end

puts "Users Created"

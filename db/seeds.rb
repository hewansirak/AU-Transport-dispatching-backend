puts "Seeding departments..."

departments = {
  hr:               "HR",
  mis:              "MIS",
  finance:          "FIN",
  procurement:      "PROC",
  legal:            "LEG",
  communications:   "COMM",
  administration:   "ADMIN",
  peace_security:   "PS",
  infrastructure:   "INFRA",
  social_affairs:   "SA",
  executive_office: "EXEC"
}

departments.each do |name_key, code|
  Department.find_or_create_by!(code: code) do |d|
    d.name = name_key
  end
end

puts "Seeding vehicles..."

[
  { plate_number: "AU-001-ET", make: "Toyota",    model: "Land Cruiser", year: 2021, vehicle_type: :suv,    capacity: 7,  status: :available },
  { plate_number: "AU-002-ET", make: "Toyota",    model: "Hiace",        year: 2020, vehicle_type: :van,    capacity: 14, status: :available },
  { plate_number: "AU-003-ET", make: "Ford",      model: "Ranger",       year: 2022, vehicle_type: :pickup, capacity: 3,  status: :available },
].each { |v| Vehicle.find_or_create_by!(plate_number: v[:plate_number]) { |r| r.assign_attributes(v) } }

puts "Seeding users and drivers..."

hr_dept    = Department.find_by!(code: "HR")
admin_dept = Department.find_by!(code: "ADMIN")

# Admin
admin = User.find_or_create_by!(email: "admin@au.int") do |u|
  u.first_name        = "System"
  u.last_name         = "Admin"
  u.password          = "Password1!"
  u.role              = :admin
  u.department        = admin_dept
  u.telephone_extension = "0000"
  u.active            = true
end

# Dispatcher
dispatcher = User.find_or_create_by!(email: "dispatcher@au.int") do |u|
  u.first_name        = "Dawit"
  u.last_name         = "Bekele"
  u.password          = "Password1!"
  u.role              = :dispatcher
  u.department        = admin_dept
  u.telephone_extension = "1001"
  u.active            = true
end

# Dispatcher supervisor
User.find_or_create_by!(email: "dispatch.supervisor@au.int") do |u|
  u.first_name        = "Amina"
  u.last_name         = "Osei"
  u.password          = "Password1!"
  u.role              = :dispatcher_supervisor
  u.department        = admin_dept
  u.telephone_extension = "1002"
  u.active            = true
end

# A supervisor for HR
hr_supervisor = User.find_or_create_by!(email: "hr.supervisor@au.int") do |u|
  u.first_name        = "Fatima"
  u.last_name         = "Diallo"
  u.password          = "Password1!"
  u.role              = :supervisor
  u.department        = hr_dept
  u.telephone_extension = "2001"
  u.active            = true
end

# A requester
User.find_or_create_by!(email: "requester@au.int") do |u|
  u.first_name        = "Kwame"
  u.last_name         = "Asante"
  u.password          = "Password1!"
  u.role              = :requester
  u.department        = hr_dept
  u.telephone_extension = "2010"
  u.active            = true
end

# 3 drivers
[
  { first_name: "Tesfaye", last_name: "Girma",   email: "driver1@au.int", phone: "+251911000001", license: "ETH-DRV-001", vehicle_type: "Land Cruiser SUV" },
  { first_name: "Oumar",   last_name: "Traore",  email: "driver2@au.int", phone: "+251911000002", license: "ETH-DRV-002", vehicle_type: "Hiace Van" },
  { first_name: "Samuel",  last_name: "Mensah",  email: "driver3@au.int", phone: "+251911000003", license: "ETH-DRV-003", vehicle_type: "Ford Ranger Pickup" },
].each do |d|
  user = User.find_or_create_by!(email: d[:email]) do |u|
    u.first_name        = d[:first_name]
    u.last_name         = d[:last_name]
    u.password          = "Password1!"
    u.role              = :driver
    u.department        = admin_dept
    u.telephone_extension = "9#{rand(100..999)}"
    u.active            = true
  end

  Driver.find_or_create_by!(license_number: d[:license]) do |dr|
    dr.user           = user
    dr.phone_number   = d[:phone]
    dr.license_expiry = 2.years.from_now
    dr.status         = :available
    dr.notes          = "Assigned vehicle type: #{d[:vehicle_type]}"
  end
end

puts "Done! Seeds loaded successfully."
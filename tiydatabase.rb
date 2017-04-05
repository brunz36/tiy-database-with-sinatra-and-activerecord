require 'sinatra'
require 'pg'
require 'awesome_print'
require 'sinatra/reloader' if development?
require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "tiy_database"
)

class Employee < ActiveRecord::Base
  self.primary_key = "id"
  validates :name, presence: true
  validates :phone, numericality: { only_integer: true }
  validates :phone, length: { is: 10 }
  validates :salary, numericality: true
  validates :position, inclusion: { in: %w{Instructor Student}, message: "%{value} must be Instructor or Student." }
end

class Course < ActiveRecord::Base
  self.primary_key = "id"
  validates :name, presence: true
  validates :intensive, inclusion: { in: [true, false] }
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb :index
end

get '/employees' do
  @employees = Employee.all

  erb :employees
end

get '/show_employee' do
  @employee = Employee.find(params["id"])

  erb :show_employee
end

get '/new_employee' do
  @employee = Employee.new

  erb :new_employee
end

get '/add_employee' do
  @employee = Employee.create(params)

  if @employee.valid?
    redirect('/employees')
  else
    erb :new_employee
  end
end

get '/search_employee' do
  search = params["search"]

  @employees = Employee.where("name like ? or github = ? or slack = ?", "%#{search}%", search, search)

  if @employees.count < 1
    redirect('/')
  else
    erb :search_employee
  end
end

get '/edit_employee' do
  id = params["id"]

  @employee = Employee.find(params["id"])

  erb :edit_employee
end

get '/append_employee' do
  @employee = Employee.find(params["id"])

  @employee.update_attributes(params)

  if @employee.valid?
    redirect to("/show_employee?id=#{@employee.id}")
  else
    erb :edit_employee
  end
end

get '/delete_employee' do
  @employee = Employee.find(params["id"])

  @employee.destroy

  redirect to ('/employees')
end

get '/courses' do
  @courses = Course.all

  erb :courses
end

get '/show_course' do
  @course = Course.find(params["id"])

  erb :show_course
end

get '/search_course' do
  search = params["search"]

  @courses = Course.where("name LIKE ?", "%#{search}%")

  if @courses.count < 1
    redirect('/')
  else
    erb :search_course
  end
end

get '/new_course' do
  @course = Course.new

  erb :new_course
end

get '/add_course' do
  @course = Course.create(params)

  if @course.valid?
    redirect('/courses')
  else
    erb :new_course
  end
end

get '/edit_course' do
  id = params["id"]

  @course = Course.find(params["id"])

  erb :edit_course
end

get '/append_course' do
  @course = Course.find(params["id"])

  @course.update_attributes(params)

  if @course.valid?
    redirect to("/show_course?id=#{@course.id}")
  else
    erb :edit_course
  end
end

get '/delete_course' do
  @course = Course.find(params["id"])

  @course.destroy

  redirect to ('/courses')
end

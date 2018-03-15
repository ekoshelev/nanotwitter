require 'bcrypt'

configure do
  enable :sessions
end

helpers do
  def authenticate!
    halt(401, 'Not Authorized') unless session[:user]
    session[:original_request] = request.path_info
  end
end

get '/fry_login' do
  if session[:user]
    "Welcome #{session[:user]}"
  else
    erb :fry_login
  end
end

post '/fry_login' do
  user = User.find_by(name: "#{params[:username]}")
  password = "#{params[:password]}"

  if BCrypt::Password.new(user.password).is_password? password
    session[:user] = user.name
    redirect to('/fry_protected_test')
  else
    "Login Failed!"
  end
end

get '/fry_protected_test' do
  authenticate!
  erb :fry_protected_test
end

get '/fry_logout' do
  session.clear
  redirect to('/fry_login')
end

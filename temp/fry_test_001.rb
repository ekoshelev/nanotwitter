get '/fry_test' do
  @users = User.all
  erb :fry_test
end

post '/fry_test' do
  @user = User.new(params[:user])
  if @user.save
    redirect '/fry_test'
  else
    'Sorry, there was an error!'
  end
end

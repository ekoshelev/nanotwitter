# Hello! I'm going to clean this up a bit- make the helpers a module, create views for pages, etc.
# This is just a start. Sorry.
helpers do
	def authenticate!
		unless session[:user]
			session[:original_request] = request.path_info
			redirect 'authentication_fail'
		end
	end
end

get '/authentication_test/?' do
	#session[:user] = User.new
	authenticate!
	"Your attempt at authentication has succeeded!"
end

get '/authentication_fail' do
	"Your attempt at authentication has failed!"
end

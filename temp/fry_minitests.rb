require 'minitest/autorun'

class CreateUser < Minitest::Test
  def try_to_create_user
    post 'fry_test' do {
      :name => "dido",
      :email => "queend@carthage.com",
      :password => "aeneas",
      :api_token => "api_token_test"}.to_json
    end

    #test_user = User.new("Dido", "queend@carthage.com", "aeneas", "api_token_test")

    #post '/fry_test' do
    #  @user = test_user
    #end

    #assert @user.save
  end
end

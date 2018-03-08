require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require 'minitest/autorun'
require './test_interface.rb'
Dir["./models/*.rb"].each {|file| require file}

class TestUser <  Minitest::Test

  def setup
    @tester = TestInterface.new
    @tester.reset_All
  end

  def test_create_user
  #  assert_equal true, User.new
    user = User.new
    user.name = "TestUser"
    user.email = "testemail@tester.com"
    user.password = "TestPassword"
    user.save

    user_test = User.first

    assert_equal "TestUser", User.first.name
    assert_equal "testemail@tester.com", User.first.email
    assert_equal "TestPassword", User.first.password

    @tester.reset_All
  end
end

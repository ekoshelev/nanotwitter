require 'json'
require 'byebug'
Dir["./lib/nanotwitter/*.rb"].each {|file| require file}

class Tweet

  def initialize(response)
    @text = response['text']
    @poster = response['poster']
    if response['user'] != nil
      @user = User.new(response['user'])
    end
  end

  attr_accessor :text, :user, :poster
end

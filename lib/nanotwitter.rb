require 'net/http'
require 'uri'
require 'json'
require 'byebug'
Dir["./lib/nanotwitter/*.rb"].each {|file| require file}

class NanoTwitter

  def initialize(name,api_token)
    @name = name
    @api_token = api_token

  end

  def get_user
    request = "{user(name: \"#{@name}\") {name id tweets {text time_created} timeline {text poster time_created}}}"
    response = JSON.parse(make_request(request))['data']
    return User.new(response['user'])
  end


  def get_user_timeline(recent = nil)

    request = "{user(name:\"#{@name}\")"

    return get_timeline(recent,request)

  end

  def get_timeline(recent = nil,req = nil)
    if recent == nil
      request = "{timeline"
    else
      request = "{timeline(recent: #{recent})"
    end


    request = request + "{text poster time_created} }"

    if req != nil
      request = req + request + "}"
    end

    response = JSON.parse(make_request(request))['data']


    if response['user'] != nil
      response = response['user']
    end

    timeline = tweet_set(response,'timeline')

    return timeline

  end

  def post_tweet(text)
    request = "{post_tweet(api_token:\"#{@api_token}\",text:\"#{text}\") {text poster} }"
    posted = JSON.parse(make_request(request))['data']
    return Tweet.new(posted['post_tweet'])
  end

  def search_tweets(term)
    request = "{search_tweets(search_term: \"#{term}\") {text poster time_created} }"

    response = JSON.parse(make_request(request))['data']

    return tweet_set(response,'search_tweets')


  end

  def search_users(term)
    request = "{search_users(search_term: \"#{term}\") {name id tweets {text} } }"

     response = JSON.parse(make_request(request))['data']

     users = []

     response['search_users'].each do |user|
       users << User.new(user)
     end

     return users


  end

  def tweet_set(response,key)
    set = []
    response["#{key}"].each do |tweet|
      set << Tweet.new(tweet)
    end
    return set
  end



  def make_request(req)
    uri = URI.parse(url)

    header = {'Content-Type': 'text/json'}
    body = { "query": req }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    http.use_ssl = true
    request.body = body.to_json
    return http.request(request).body
  end

  def url
    "https://nanotwitternotfound404.herokuapp.com/api/v1/graphql"
  end

end

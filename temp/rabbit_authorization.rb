# Okay. This is not really a clever way of doing this. At all. We set it up to see if we could implement
# RabbitMQ, which we could. Ideally, we would get this up and running on a separate dyno as a proper
# microservice rather than just sort of hanging out in the main program with an artifically enforced
# synchronicity. So... proof of concept?

require 'bunny'
require 'json'
require 'bcrypt'

def rabbitmq_authorization(user_parameters)
  user_parameters = user_parameters.to_json.to_s

  rabbitmq_sender(user_parameters)
  rabbitmq_receiver
end

def rabbitmq_sender(user_parameters)
  connection = Bunny.new(automatically_recover: false)
  connection.start

  channel = connection.create_channel
  queue = channel.queue('register_queue', durable: true)
  queue.publish(user_parameters)

  connection.close
end

def rabbitmq_receiver
  connection = Bunny.new(automatically_recover: false)
  connection.start

  channel = connection.create_channel
  queue = channel.queue('register_queue', durable: true)
  channel.prefetch(1)

  begin
    queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, user_parameters|
      @register_success = register_check(user_parameters)
      channel.ack(delivery_info.delivery_tag)

      # Ordinarily, this connection should not be closed here. This is how we're 'forcing' synchronicity.
      connection.close
    end
  rescue Interrupt =>
    connection.close
  end

  if @register_success
    session[:user] = @user
    redirect '/display'
  else
    redirect '/'
  end

  redirect '/rabbit_test_success'
end

def register_check(user_parameters)
  user_parameters = JSON.parse(user_parameters)
  user_check = User.find_by(name: "#{user_parameters["name"]}")

  if (!user_check.nil? || user_parameters["password"] != user_parameters["confirm-password"])
    false
  else
    @user = User.new
    @user.name = user_parameters["name"]
    @user.email = user_parameters["email"]
    @user.password = BCrypt::Password.create(user_parameters["password"])
    @user.save

    true
  end
end

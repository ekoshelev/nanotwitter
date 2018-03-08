require 'csv'

### Note- there's no reason for the names to be set to lowercase.
###   For the moment, I just found it easier for manual inspections/manipulations.
###   Feel free to remove it if you like.

# ### So, we have 'followers', and the seed data has 'follows'.
# ### I'm interpreting their data as {first_id} is following {second_id}.
# ### So we implement that as {second_id} has the follower {first_id}.

def seed_table(csv_file_name, table_name, table_columns)
  csv_entries = CSV.parse(File.read("lib/seeds/#{csv_file_name}"))

  table_values = csv_entries.map do |csv_row|
    table_row = manual_mapping(table_name, csv_row)
  end

  table_values = table_values.join(",")

  ActiveRecord::Base.connection.execute("INSERT INTO #{table_name} #{table_columns} VALUES #{table_values};")
end

def manual_mapping(table_name, csv_row)
  case table_name
  when "users"
    name = csv_row[1].gsub("'", "''").downcase
    email = "#{name}@example.com"
    password = name.reverse
    api_token = csv_row[0]

    table_row = "('#{name}','#{email}','#{password}','#{api_token}')"
  when "tweets"
    text = csv_row[1].gsub("'", "''")
    time_created = csv_row[2]
    user_id = csv_row[0]

    table_row = "('#{text}','#{time_created}','#{user_id}')"
  when "followers"
    user_id = csv_row[1]
    follower_id = csv_row[0]

    table_row = "('#{user_id}','#{follower_id}')"
  end
end

#t1 = Time.now
seed_table("users.csv", "users", "(name, email, password, api_token)")
seed_table("tweets.csv", "tweets", "(text, time_created, user_id)")
seed_table("follows.csv", "followers", "(user_id, follower_id)")
#t2 = Time.now

#puts (t2 - t1).round(2)

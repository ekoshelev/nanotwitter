require 'csv'

### Note- there's no reason for the names to be set to lowercase.
###   For the moment, I just found it easier for manual inspections/manipulations.
###   Feel free to remove it if you like.

# ### So, we have 'followers', and the seed data has 'follows'.
# ### I'm interpreting their data as {first_id} is following {second_id}.
# ### So we implement that as {second_id} has the follower {first_id}.

def seed_table(csv_file_name, table_name, table_columns, cutoff = nil)
  csv_entries = CSV.parse(File.read("lib/seeds/#{csv_file_name}"))
  csv_entries = csv_entries.first(cutoff.to_i) if !cutoff.nil?

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
    password = BCrypt::Password.create(name.reverse)
    #password = digest(name.reverse)
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


def digest(string)
  cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                BCrypt::Engine.cost
  BCrypt::Password.create(string, cost: cost)
end

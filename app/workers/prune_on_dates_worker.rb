class PruneOnDatesWorker
  include Sidekiq::Worker
  include ValueConversions
  def perform(db_name,table_name,from_date,to_date)
    offset = 0
    loop do 
      db_master_conn = ActiveRecord::Base.establish_connection("postgres://housing:housing@db.dev.housing.com/#{db_name}")
      sql_retrive = "SELECT * FROM #{table_name} WHERE created_at BETWEEN '#{from_date}' AND '#{to_date}' ORDER BY 1 LIMIT 1000 OFFSET #{offset} "
      table = db_master_conn.connection.execute(sql_retrive)
      values = values_generator(table)
      db_prune_conn = ActiveRecord::Base.establish_connection("postgres://housing:housing@localhost/#{db_name}")
      sql_insert =  "INSERT INTO #{table_name} VALUES #{values}"
      db_prune_conn.connection.execute(sql_insert_all)
      if table.num_tuples < 1000
        break
      end
      offset = offset + 1000
    end
  end
end

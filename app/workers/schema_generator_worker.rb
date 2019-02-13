class SchemaGeneratorWorker
  include Sidekiq::Worker
  require 'pg'
  require 'ruby_expect'

  def perform(host_name,port_no,user_name,password,db_name)
    dump_file_name = db_name + ".dump"
    exp = RubyExpect::Expect.spawn("pg_dump --host #{host_name}  --port #{port_no} --username #{user_name} --file #{dump_file_name} -s #{db_name}")
    exp.procedure do
      each do
        expect "Password:" do
          send password
        end
        expect /\$\s*$/ do
          send ""
        end
      end
    end
    exp = RubyExpect::Expect.spawn("createdb -h localhost -p 5432 -U #{user_name} #{db_name}")
    exp.procedure do
      each do
        expect "Password:" do
          send password
        end
        expect /\$\s*$/ do
          send ""
        end
      end 
    end
    exp = RubyExpect::Expect.spawn("psql -U #{user_name} -d #{db_name} -f #{dump_file_name}")
    exp.procedure do
      each do
        expect "Password for user #{user_name}:" do
          send password
        end
        expect /\s*/ do
          send ""
        end
        expect /\$\s*$/ do
          send ""
        end
      end
    end
  end
end


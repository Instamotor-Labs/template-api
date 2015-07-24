include ActiveRecord::Tasks
DatabaseTasks.database_configuration = YAML.load(ERB.new(File.read('config/database.yml')).result)
DatabaseTasks.env = 'test'

ActiveRecord::Base.configurations       = DatabaseTasks.database_configuration || {}
ActiveRecord::Base.maintain_test_schema = true
ActiveRecord::Migrator.migrations_paths = DatabaseTasks.migrations_paths

def test_db_automaintenance(db_config = :test)
  ActiveRecord::Base.establish_connection(DatabaseTasks.database_configuration[db_config.to_s])
  schema_filename = db_config == :test ? 'schema.rb' : 'harvester_schema.rb'
  begin
    ActiveRecord::Migration.suppress_messages do
      if ActiveRecord::Migrator.needs_migration?
        DatabaseTasks.load_schema_current(:ruby, File.join(DatabaseTasks.db_dir, schema_filename), db_config.to_s)
        check_pending!
      end
    end
  rescue
    DatabaseTasks.create_current(db_config.to_s)
    ActiveRecord::Migration.suppress_messages do
      DatabaseTasks.load_schema_current(:ruby, File.join(DatabaseTasks.db_dir, schema_filename), db_config.to_s)
    end
  end
end

test_db_automaintenance(:test)
test_db_automaintenance(:harvester_test)
ActiveRecord::Base.establish_connection(:test)
# require 'json'
require 'bundler'
require 'pry'
require 'mongo'
require 'mongoid'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
	
def require_db(file)
  relative_path_to_db = 'lib/rcs-db/'
  relative_path_file = File.join(Dir.pwd, relative_path_to_db, file)

  if File.exist?(relative_path_file) or File.exist?(relative_path_file + ".rb")
    require_relative relative_path_file
  else
    raise "Could not load #{file}"
  end
end

def require_aggregator(file)
  relative_path_to_db = 'lib/rcs-aggregator/'
  relative_path_file = File.join(Dir.pwd, relative_path_to_db, file)

  if File.exist?(relative_path_file) or File.exist?(relative_path_file + ".rb")
    require_relative relative_path_file
  else
    raise "Could not load #{file}"
  end
end

def require_intelligence(file)
  relative_path_to_db = 'lib/rcs-intelligence/'
  relative_path_file = File.join(Dir.pwd, relative_path_to_db, file)

  if File.exist?(relative_path_file) or File.exist?(relative_path_file + ".rb")
    require_relative relative_path_file
  else
    raise "Could not load #{file}"
  end
end

def connect_mongoid
  ENV['MONGOID_ENV'] = 'yes'
  ENV['MONGOID_DATABASE'] = 'rcs-test'
  ENV['MONGOID_HOST'] = 'localhost'
  ENV['MONGOID_PORT'] = '27017'

  Mongoid.load!('config/mongoid.yaml', :production)
end

def empty_test_db
  Mongoid.purge!
end

def require_sharded_db
  conn = Mongo::MongoClient.new(ENV['MONGOID_HOST'], ENV['MONGOID_PORT'])
  db = conn.db('admin')
  list = db.command({ listshards: 1 })
  db.command({addshard: ENV['MONGOID_HOST'] + ':27018'}) if list['shards'].size == 0
  db.command({enablesharding: ENV['MONGOID_DATABASE']}) rescue nil
end

class FakeLog4rLogger
  def method_missing *args; end
  # Prevent calling Kernel#warn with send
  def warn *args; end
end

# Check out RCS::Tracer module of rcs-common gem
def turn_off_tracer
  @fakeLog4rLogger ||= FakeLog4rLogger.new
  Log4r::Logger.stub(:[]).and_return @fakeLog4rLogger
end

def turn_on_tracer
  Log4r::Logger.stub(:[]).and_return nil
end

def use_db
  before(:all) { connect_mongoid}

  before :each do
    turn_off_tracer
    empty_test_db
    Entity.any_instance.stub(:alert_new_entity).and_return nil
  end

  after(:each) { empty_test_db }
end

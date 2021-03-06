require 'rake'
require 'rbconfig'

# rspec
require 'rspec/core/rake_task'

def default_rspec_opts
  "--color --tag ~speed:slow --tag ~build:true --order rand"
end

def default_rspec_opts_slow
  "--color --order rand"
end

def rspec_tasks
  {
    all: 'spec/**/*_spec.rb',
    db: 'spec/**/rcs-db/**/*_spec.rb',
    rest: 'spec/**/rcs-db/rest/*_spec.rb',
    aggregator: '{spec/**/rcs-aggregator/**/*_spec.rb,spec/lib/rcs-db/db_objects/aggregate_spec.rb,spec/lib/rcs-db/position/po*_spec.rb}',
    intelligence: '{spec/**/rcs-intelligence/**/*_spec.rb,spec/lib/rcs-db/db_objects/entity_spec.rb,spec/lib/rcs-db/link_manager_spec.rb}',
    ocr: 'spec/**/rcs-ocr/**/*_spec.rb'
  }
end

def platforms
  ['all', 'android', 'blackberry', 'ios', 'linux', 'osx', 'symbian', 'windows', 'winmo', 'winphone']
end

rspec_tasks.each do |task_name, pattern|

  desc "Run RSpec test (#{task_name})"
  RSpec::Core::RakeTask.new("spec:#{task_name}") do |test|
    test.rspec_opts = default_rspec_opts
    test.pattern = pattern
  end

  desc "Run RSpec test (#{task_name}) including slow examples"
  RSpec::Core::RakeTask.new("spec:#{task_name}:slow") do |test|
    test.rspec_opts = default_rspec_opts_slow
    test.pattern = pattern
  end
end

platforms.each do |platform|
  desc "Run RSpec build test (#{platform})"
  RSpec::Core::RakeTask.new("spec:build:#{platform}") do |test|
    test.rspec_opts = default_rspec_opts
    platform = '**' if platform.eql? 'all'
    test.pattern = "spec/lib/rcs-db/build/#{platform}_spec.rb"
  end
end

desc 'Alias for "rake spec:all"'
task :test do
  Rake::Task['spec:all'].invoke
end

desc 'Alias for "rake spec:all"'
task :spec do
  Rake::Task['spec:all'].invoke
end

task :default => :test


def execute(message)
  print message + '...'
  STDOUT.flush
  if block_given?
    yield
  end
  puts ' ok'
end

def collector_relative_path
  unix_path, win_path = '../rcs-collector', '../Collector'
  Dir.exists?(win_path) && win_path || unix_path
end

def invoke_collector_task task_name
  system("cd #{collector_relative_path} && rake #{task_name}") || raise("Unable to call rake #{task_name} on the collector")
end


desc "Housekeeping for the project"
task :clean do
  execute "Cleaning the log directory" do
    Dir['./log/*.log'].each do |f|
      File.delete(f)
    end
  end
end

desc "Install rcs-common gem system wide"
task :rcs_common_gem do
  execute "Installing rcs-common gem system wide" do
    current_path = File.dirname(__FILE__)
    gem_path = File.expand_path(File.join(current_path, '../rcs-common'))
    Dir.chdir(gem_path)
    system("rake protect:install")
    Dir.chdir(current_path)
  end
end

desc "Create export.zip assets archive (evidence export)"
task :export_zip do
  execute "Creating export.zip" do
    config_path = File.expand_path('../config', __FILE__)
    target = "#{config_path}/export.zip"
    srcs = "#{config_path}/export.zip.src/"

    FileUtils.rm(target) if File.exists?(target)

    # Note the -D options (do not add directory entries)
    system("cd \"#{srcs}\" && zip -r -D \"#{target}\" .")
  end
end

desc "Create the NSIS installer for windows"
task :nsis do
  puts "Housekeeping..."
  Rake::Task[:clean].invoke
  Rake::Task[:protect].invoke
  Rake::Task[:rcs_common_gem].invoke

  puts "Protecting collector code..."
  invoke_collector_task :protect

  VERSION = File.read('config/VERSION_BUILD')
  MAKENSIS = "\"C:\\Program Files (x86)\\NSIS\\makensis.exe\""

  FileUtils.rm_rf "./nsis/rcs-exploits-#{VERSION}.exe"
  FileUtils.rm_rf "./nsis/rcs-agents-#{VERSION}.exe"
  FileUtils.rm_rf "./nsis/rcs-setup-#{VERSION}.exe"
  FileUtils.rm_rf "./nsis/rcs-ocr-#{VERSION}.exe"
  FileUtils.rm_rf "./nsis/rcs-translate-#{VERSION}.exe"

  execute 'Generating RCS-Exploit NSIS installer...' do
 		system "#{MAKENSIS} /V1 ./nsis/RCS-Exploits.nsi"
	end
	execute 'Signing RCS-Exploits installer...' do
		system "./nsis/SignTool.exe sign /P GeoMornellaChallenge7 /f ./nsis/HT.pfx ./nsis/rcs-exploits-#{VERSION}.exe"
	end

	execute 'Generating RCS-Agent NSIS installer...' do
		system "#{MAKENSIS} /V1 ./nsis/RCS-Agents.nsi"
	end
	execute 'Signing RCS-Agents installer...' do
		system "./nsis/SignTool.exe sign /P GeoMornellaChallenge7 /f ./nsis/HT.pfx ./nsis/rcs-agents-#{VERSION}.exe"
	end

	execute 'Generating RCS NSIS installer...' do
		system "#{MAKENSIS} /V1 ./nsis/RCS.nsi"
	end
	execute 'Signing RCS installer...' do
		system "./nsis/SignTool.exe sign /P GeoMornellaChallenge7 /f ./nsis/HT.pfx ./nsis/rcs-setup-#{VERSION}.exe"
  end

  execute 'Generating RCS-OCR NSIS installer...' do
    system "#{MAKENSIS} /V1 ./nsis/RCS-OCR.nsi"
  end
  execute 'Signing RCS-OCR installer...' do
    system "./nsis/SignTool.exe sign /P GeoMornellaChallenge7 /f ./nsis/HT.pfx ./nsis/rcs-ocr-#{VERSION}.exe"
  end

  execute 'Generating RCS-Translate NSIS installer...' do
    system "#{MAKENSIS} /V1 ./nsis/RCS-Translate.nsi"
  end
  execute 'Signing RCS-Translate installer...' do
    system "./nsis/SignTool.exe sign /P GeoMornellaChallenge7 /f ./nsis/HT.pfx ./nsis/rcs-translate-#{VERSION}.exe"
  end

  execute 'Generating RCS-Money NSIS installer...' do
    system "#{MAKENSIS} /V1 ./nsis/RCS-Money.nsi"
  end

  execute 'Signing RCS-Money installer...' do
    system "./nsis/SignTool.exe sign /P GeoMornellaChallenge7 /f ./nsis/HT.pfx ./nsis/rcs-money-#{VERSION}.exe"
  end
end

$modules = %w[db worker aggregator intelligence ocr translate connector money]

desc "Remove the protected release code"
task :unprotect do
  execute "Deleting the protected release folder" do
    FileUtils.rm_rf "bin-release"
    FileUtils.rm_rf(Dir.pwd + '/rgloader') if File.exist?(Dir.pwd + '/rgloader')

    $modules.each do |name|
      FileUtils.rm_rf(Dir.pwd + "/lib/rcs-#{name}-release") if File.exist?(Dir.pwd + "/lib/rcs-#{name}-release")
    end
  end
end

case RbConfig::CONFIG['host_os']
  when /darwin/
    paths = ['/Applications/Development/RubyEncoder.app/Contents/MacOS', '/Applications/RubyEncoder.app/Contents/MacOS']
    RUBYENCPATH = File.exists?(paths.first) ? paths.first : paths.last
    RUBYENC = "#{RUBYENCPATH}/rgencoder"
  when /mingw/
    RUBYENCPATH = 'C:/Program Files (x86)/RubyEncoder'
    RUBYENC = "\"C:\\Program Files (x86)\\RubyEncoder\\rgencoder.exe\""
end

desc "Create the encrypted code for release"
task :protect do
  Rake::Task[:unprotect].invoke

  execute "Creating release folder" do
    $modules.each do |name|
      Dir.mkdir(Dir.pwd + "/lib/rcs-#{name}-release") if not File.directory?(Dir.pwd + "/lib/rcs-#{name}-release")
    end
  end

  execute "Copying the rgloader" do
    RGPATH = RUBYENCPATH + '/Loaders'
    Dir.mkdir(Dir.pwd + '/rgloader') rescue puts("Folder /rgloader already exists.")
    files = Dir[RGPATH + '/**/**']
    # keep only the interesting files (2.0.x windows, macos)
    files.delete_if {|v| v.match(/bsd/i) or v.match(/linux/i)}
    files.keep_if {|v| v.match(/20/) or v.match(/loader.rb/) }
    files.each do |f|
      FileUtils.cp(f, Dir.pwd + '/rgloader')
    end
  end

  execute "Encrypting code" do

    # Copy the bin folder to bin-release and encode it
    # Note: The rcs-license-check script is used during the installation
    FileUtils.rm_rf("bin-release")
    FileUtils.cp_r("bin", "bin-release")
    FileUtils.cp("lib/rcs-license-check.rb", "bin-release/rcs-license-check")

    Dir["bin-release/*"].each do |path|
      extname = File.extname(path).downcase
      is_ruby_script = (extname == ".rb") || (extname.empty? and File.read(path) =~ /\#\!.+ruby/i)
      next unless is_ruby_script
      system "#{RUBYENC} --stop-on-error --encoding UTF-8 -b- --ruby 2.0.0 #{path}" || raise("Econding failed.")
    end

    # we have to change the current dir, otherwise rubyencoder
    # will recreate the lib/rcs-db structure under rcs-db-release
    $modules.each do |name|
      Dir.chdir "lib/rcs-#{name}/"
      system "#{RUBYENC} --stop-on-error --encoding UTF-8 -o ../rcs-#{name}-release -r --ruby 2.0.0 *.rb */*.rb" || raise("Econding failed.")
      Dir.chdir "../.."
    end
  end

  execute "Copying other files" do
    $modules.each do |project_name|
      Dir["#{Dir.pwd}/lib/rcs-#{project_name}/**/*"].each do |p|
        next if Dir.exists?(p)
        next if File.extname(p) =~ /\.rb/i
        dest_folder = File.dirname(p).gsub("lib/rcs-#{project_name}", "lib/rcs-#{project_name}-release")
        dest_file = File.join(dest_folder, File.basename(p))
        FileUtils.mkdir_p(dest_folder)
        FileUtils.cp_r(p, dest_file)
      end
    end
  end
end

require 'rcs-common/deploy'
ENV['DEPLOY_USER'] = 'Administrator'
ENV['DEPLOY_ADDRESS'] = '192.168.100.100'
RCS::Deploy::Task.import

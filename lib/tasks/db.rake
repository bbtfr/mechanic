namespace :db do

  desc "Dumps the database to backups"
  task :dump => :environment do
    cmd = nil
    with_config do |app, database_url|
      cmd = "pg_dump -F c -v #{database_url} -f #{Rails.root}/db/backups/#{Time.now.strftime("%Y%m%d%H%M%S")}.psql"
    end
    puts cmd
    exec cmd
  end

  desc "Restores the database from backups"
  task :restore, [:date] => :environment do |task, args|
    if args.date.present?
      cmd = nil
      with_config do |app, database_url|
        cmd = "pg_restore -F c -v -c -C #{Rails.root}/db/backups/#{args.date}.psql"
      end
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      puts cmd
      exec cmd
    else
      puts 'Please pass a date to the task'
    end
  end

  private

  def with_config
    config = ActiveRecord::Base.connection_config

    yield Rails.application.class.parent_name.underscore,
      "postgres://#{config[:username]}:#{config[:password]}@#{config[:host]}/#{config[:database]}"
  end

end

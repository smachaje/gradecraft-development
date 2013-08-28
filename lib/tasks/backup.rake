namespace :backup do
  task :db => :environment do
    database_config = Rails.configuration.database_configuration[Rails.env]
    filename = "#{database_config['database']}_#{Time.now.utc.strftime('%F')}.sql.gz"
    system "pg_dump -h localhost -p 5432 -U #{database_config['username']} #{database_config['database']} | gzip -c > db/backups/#{filename}"
    system "s3cmd put db/backups/#{filename} s3://gradecraft.#{Rails.env}/backups/db/#{filename}"
    puts "\nUploaded database dump to S3.\n\n"
  end
end

task :backup => 'backup:db'

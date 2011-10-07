require 'csv'
require 'fileutils'

csv_file = File.join(File.dirname(__FILE__), 'resources', 'nfl-teams.csv')

IN_DIR = '/Users/jprichardson/Desktop/PushCerts/'

Dir.mkdir(OUT_DIR) unless Dir.exists?(OUT_DIR)

files = Dir.entries(IN_DIR).find_all{|f| !f.start_with?('.') }

CSV.foreach(csv_file, headers: :frontrow) do |row|
  if row['bundle_id'] != ''
    is_match = false
    out_loc = "root@data.mobilefanapps.com:/var/www/current/keys/#{row['id']}.pem"
    files.each do |file|
      in_file = IN_DIR + file
      if file.include?(row['bundle_id'])
        puts("Copying #{in_file} to #{out_loc}...")
        is_match = true
        `scp -P 59999 #{in_file} root@data.mobilefanapps.com:/var/www/current/keys/.`
        break;
      end
    end

    puts "No match for #{row['bundle_id']}." unless is_match
  end
end


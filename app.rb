#requires that public key is copied over to data.mobilefanapps.com
#cat .ssh/id_rsa.pub | ssh root@data.mobilefanapps.com 'cat >> .ssh/authorized_keys'

require 'csv'
require 'fileutils'

TEAM_CSV  = $ARGV[0]
IN_DIR    = '/Users/marcmauger/Desktop/PushCerts/' 
SSH_USER  = 'deploy'

unless TEAM_CSV && File.exists?(TEAM_CSV)
  puts "Usage: app.rb team_csv_file"
  exit
end
files = Dir.entries(IN_DIR).find_all{|f| !f.start_with?('.') }

CSV.foreach(TEAM_CSV, {headers: :first_row}) do |row|
  if row['bundle_id'] != ''
    is_match = false
    out_loc = "#{SSH_USER}@data.mobilefanapps.com:/var/apns/keys/#{row['id']}.pem"
    files.each do |file|
      in_file = IN_DIR + file
      if file.include?(row['bundle_id'])
        puts("Copying #{in_file} to #{out_loc}...")
        is_match = true
        `scp -P 59999 #{in_file} #{out_loc}`
        break;
      end
    end

    puts "No match for #{row['bundle_id']}." unless is_match
  end
end


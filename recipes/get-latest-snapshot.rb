#!/usr/bin/env ruby

# Run with  ruby -rubygems get-latest-snapshot.rb qa-dbm us-east-1
#	snapshot_name = "qa-dbm"
#	region = "us-east-1"

require 'fog'

unless defined? node
	snapshot_name = ARGV[0]
	region = ARGV[1]
else
	region = node.attribute["region"]
	snapshot_name = node.attribute["snapshot_name"]
end

attributes = {
	:provider => 'AWS',
	:aws_access_key_id => 'AKIAJBQME4ZIHUI4KBBA',
	:aws_secret_access_key => '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',
	:region => region
}

AWS = Fog::Compute.new(attributes)

# Grab the list of all snapshots
snapshots  = AWS.snapshots.all

latest_snapshot = ""
latest_snapshot_date = nil

snapshots.each do |snap|
	unless snap.description.nil?
		unless (snap.description.index(snapshot_name).nil?) 
			snapshot_date = Time.parse(snap.description[(snapshot_name.length + 1)..-1])
			if latest_snapshot_date.nil?
				latest_snapshot = snap.id
				latest_snapshot_date = snapshot_date
			else
				if latest_snapshot_date < snapshot_date
					latest_snapshot = snap.id
					latest_snapshot_date = snapshot_date
				end
			end
		end
	end
end

puts "Latest snapshot " + latest_snapshot
puts "Latest snapshot date " + latest_snapshot_date.inspect
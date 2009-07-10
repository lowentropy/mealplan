namespace :mealplan do

	desc 'Parse USDA portions into normalized form.'
	task :parse_portions => :environment do

		UsdaPortion.first.amount # whyyyyyy?

		broken = Portion.broken.count
		all = Portion.count
		puts "\nFixing #{broken} broken of #{all} total portions."

		fixed = 0
		Portion.broken.each do |portion|
			if portion.parse!.is_a? String
				putc '.'
			else
				putc '+'
				fixed += 1
			end
			$stdout.flush
		end

		puts "\nFixed #{fixed} additional portions."

		if fixed < broken
			puts "\nSome remaining problems:"
			Portion.broken.all[0,50].each do |portion|
				puts "\t#{portion.parse!}"
			end
		end

	end
end

namespace :mealplan do

	desc 'define utilities used by parsing'
	task :util => :environment do

		class Array
			def find_as
				each do |item|
					value = yield item
					return value if value
				end
				nil
			end
			def select_as(&block)
				map(&block).select {|x| x}
			end
		end

		def read_word_list(filename, position, pluralize=false)
			lines = File.readlines(filename).map {|l| l.strip}
			if pluralize
				lines = lines.map {|l| l.pluralize} + lines
			end
			lines.map do |string|
				case position
					when :leading  then /^(#{string})/
					when :trailing then /(#{string})$/
				end
			end
		end

		def read_subs_list(filename)
			returning(subs = {}) do
				File.readlines(filename).each do |line|
					key, val = line.strip.split ' -> '
					subs[key] = val
				end
			end
		end

		def apply_mods(mods, string, position, swap_if_none=false)
			found = mods.find_as do |regex|
				if string =~ regex
					returning($1) do
						string = case position
							when :leading  then string[$1.size..-1]
							when :trailing then string[0...-$1.size]
						end.strip
					end
				end
			end
			if found.nil? and swap_if_none
				[string, nil]
			else
				[found, string]
			end
		end
	end

	desc 'Parse USDA portions into normalized form.'
	task :parse_portions => :util do

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

	desc 'Parse USDA foods into normalized foods'
	task :parse_foods => :util do
		# load word-lists
		leading_mods = read_word_list('doc/leading-mods', :leading, false)
		trailing_mods = read_word_list('doc/trailing-mods', :trailing, false)
		leading_foods = read_word_list('doc/leading-foods', :leading, false)
		trailing_foods = read_word_list('doc/trailing-foods', :trailing, true)
		manufacturers = read_word_list('doc/manufacturers', :leading, false)
		substitutions = read_subs_list('doc/substitutions')
		# group foods by their (suspected) primary name
		foods = {}
		groups = UsdaFood.all.group_by do |food|
			food.long_desc.split(/,\s*/)[0].downcase
		end
		# process each primanry-name group
		groups.keys.each do |key|
			string = key.clone
			# if string contains (...), set 'desc'
			desc = if string =~ /(.*)\(([^)]*)\)(.*)/
				returning($2) do
					string = ($1.strip + " " + $3.strip).strip
				end
			end
			manufacturer, string = apply_mods(manufacturers, string, :leading)
			substitutions.each {|key,val| string.sub! /#{key}/, val}
			# TODO apply 'or' rule
			mod1, string = apply_mods(trailing_mods, string, :trailing)
			mod2, string = apply_mods(leading_mods, string, :leading)
			string, mod3 = apply_mods(trailing_foods, string, :trailing, true)
			string, mod4 = apply_mods(leading_foods, string, :leading, true)
			modifiers = [mod1,mod2,mod3,mod4].reject {|x| x.blank?}
			# now loop the actual foods
			groups[key].each do |food|
				mods = modifiers + food.long_desc.split(/,\s*/)[1..-1]
				(foods[string.singularize] ||= []) << [mods.uniq, manufacturer, desc]
			end
		end
		# print results
		foods.keys.sort.each do |key|
			puts(key.blank? ? "[blank]" : key)
			foods[key].each do |variant|
				mods, manuf, desc = variant
				mods = ['(default)'] if mods.empty?
				desc = " (#{desc})" if desc
				manuf = " [#{manuf}]" if manuf
				puts "\t#{mods.join(', ')}#{desc}#{manuf}"
			end
		end
	end

end

def load_usda(model, file)
	puts "loading usda data from #{file}"
	opts = {	:headers 		=> true,
						:col_sep 		=> '^',
						:quote_char => '~' }
	num = 0
	FasterCSV.foreach(file, opts) do |row|
		cols = row.to_hash
		vals = {}
		cols.each do |k,v|
			next if k == 'unused'
			name, type = k.split ':'
			begin
				vals[name] = case type
					when 'id' then Integer("0d#{v}")
					when 'str' then v
					when 'bool' then v == 'Y'
					when 'int' then v ? Integer(v) : nil
					when 'float' then v ? Float(v) : nil
					else raise "unknown conversion: #{type}"
				end
			rescue
				puts "failed on column #{k}"
				puts "row = #{row}"
				fail
			end
		end
		id = vals.delete 'id'
		rec = model.new vals
		rec.id = id if id
		rec.save!
		num += 1
		if num % 100 == 0
			$stdout.putc '.'
			$stdout.flush
		end
	end
	puts "\n"
end

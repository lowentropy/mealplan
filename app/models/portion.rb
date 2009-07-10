class Portion < ActiveRecord::Base
	
	AMOUNT = /^([0-9.-]+)(\/ ?[0-9]+)?\s*(\w[\w\s]+)$/
	NLEA = /^nlea serving(( size)? = (.*))?$/i

	class ParseError < RuntimeError; end

	belongs_to :piece
	belongs_to :manufacturer
	has_and_belongs_to_many :modifiers
	belongs_to :usda_portion
	belongs_to :unit

	named_scope :broken, :conditions => {:broken => true}

	# parse properties
	def parse!
		begin
			self.amount = usda_portion.amount
			self.broken = false
			return nil if usda_portion.amount.blank?
			regex1 = /^(\w[^,(]*)(,[^(]+)?(\((.*)\))?$/
			regex2 = /^(\w[^,(]*)(\((.*)\))([,\s][^(]+)?$/
			if match = regex1.match(usda_portion.desc)
				parse_name!				match[1]
				parse_modifiers!	match[2]
				parse_desc!				match[4]
			elsif match = regex2.match(usda_portion.desc)
				parse_name!				match[1]
				parse_modifiers!	match[4]
				parse_desc!				match[3]
			else
				raise ParseError.new("didn't match") 
			end
		rescue ParseError => error
			self.broken = true
			return "#{error.message} (#{usda_portion.desc})"
		rescue
			self.broken = true
			fail
		ensure
			save!
		end
	end

private

	def parse_name!(name)
		raise ParseError.new("name not provided!") unless name
		name.strip!
		if unit = Unit.search(name)
			self.unit = unit
		elsif piece = Piece.search(name)
			self.piece = piece
		elsif mod = Modifier.search(name)
			self.modifiers << mod
		elsif match = /^(.*)\s+or\s+(.*)$/.match(name)
			parse_name! match[1]
			self.desc = "or #{match[2]}"
		elsif match = NLEA.match(name)
			self.piece = Piece.search('serving')
			parse_amount! match[3] if match[3]
		elsif match = /^(.*) container$/.match(name)
			self.piece = Piece.search('container')
			parse_amount! match[1]
		elsif match = /^(.* )#{AMOUNT.source}$/.match(name)
			parse_name! match[1].strip
			parse_amount! name[match[1].size..-1]
		elsif match = /^(\w+)\s+(.*)$/.match(name)
			parse_name! match[1]
			parse_any! match[2]
		else
			raise ParseError.new("can't find primary unit '#{name}'")
		end
	end

	def parse_any!(string)
		string.strip!
		if match = /(yields|amount.*to make) (.*)/.match(string)
			self.yields = match[2]
		elsif match = NLEA.match(string)
			self.piece = Piece.search('serving')
			parse_amount! match[3] if match[3]
		elsif match = AMOUNT.match(string)
			parse_amount! string
		elsif match = /yield from (.*)/.match(string)
			self.yield_from = match[1]
		else
			man, extra = find_manufacturer(string)
			if man
				self.manufacturer = man
				self.product = extra
			elsif mod = Modifier.search(string)
				self.modifiers << mod unless modifiers.include?(mod)
			else
				raise ParseError.new("unknown modifier '#{string}'")
			end
		end
	end

	def parse_amount!(amount)
		if amount =~ /[0-9] (nlea )?servings?/i
			self.desc = amount
			return
		end
		match = AMOUNT.match(amount)
		raise "bad amount '#{amount}'" unless match
		num = match[1].to_f
		num /= match[2][1..-1].to_f if match[2]
		if num == 0.0
			raise ParseError.new("bad number in amount '#{amount}'")
		end
		if match[3] =~ /prepared$/
			self.yields = amount[0...-9]
		elsif unit = Unit.search(match[3])
			self.unit = unit
			self.unit_amount = num
		elsif piece = Piece.search(match[3])
			self.piece = piece
			if self.amount != 1.0 and
				 self.amount != num
				raise ParseError.new("conflicing amounts: #{self.amount} vs #{num}")
			end
			self.amount = num
		else
			raise ParseError.new("bad amount '#{amount}'")
		end
	end

	def parse_modifiers!(modifiers)
		return unless modifiers
		modifiers = modifiers.split(/,\s*/)
		modifiers.shift if modifiers[0].blank?
		(modifiers || []).each do |modifier|
			parse_any! modifier
		end
	end

	def parse_desc!(desc)
		return unless desc
		desc.strip!
		if match = /^(yields|makes|net weight,?)\s+(.*)$/.match(desc)
			self.yields = match[2]
		elsif match = /^yield after/.match(desc)
			self.desc = desc
		elsif match = /^yield f?rom (.*)$/.match(desc)
			self.yield_from = match[1]
		elsif match = /^approx/.match(desc)
			self.desc = desc
		elsif match = /"/.match(desc)
			self.desc = desc
		elsif match = / per /.match(desc)
			self.desc = desc
		else
			parse_any! desc
		end
	end

	def find_manufacturer(text)
		if text.strip.blank?
			raise ParseError.new("empty modifier")
		end
		words = text.split /\s+/
		name = words.shift
		while true
			if man = Manufacturer.search(name)
				return man, words.join(' ')
			end
			break if words.empty?
			name = name + " " + words.shift
		end
		return nil, nil
	end
end

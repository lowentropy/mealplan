class Portion < ActiveRecord::Base
	belongs_to :piece
	has_and_belongs_to_many :modifiers
	belongs_to :usda_portion
	belongs_to :unit

	def parse!
		begin
			regex = /^(\w+(\s+\w+)*)(,\s*\w+)*(\s*\((.*)\))?$/
			match = regex.match(usda_portion.desc)
			raise "didn't match #{usda_portion.desc}" if match.nil?
			parse_name!				match[1]
			parse_modifiers!	match[3]
			parse_desc!				match[5]
		rescue
			self.broken = true
			return $!.message
		ensure
			save!
		end
	end

private

	def parse_name!(name)
		if unit = Unit.search(name)
			self.unit = unit
		elsif piece = Piece.search(name)
			self.piece = piece
		else
			raise "can't find unit or piece #{name}"
		end
	end

	def parse_modifiers!(modifiers)
		modifiers = modifiers.split(/,\s*/)[1..-1]
		(modifiers||[]).each do |modifier|
			mod = Modifier.search(modifier)
			raise "can't find modifier #{modifier}" if mod.nil?
			self.modifiers << mod
		end
	end

	def parse_desc!(desc)
		return unless desc
		if desc =~ /\s/
			index = desc.index /\s/
			amount = desc[0,index].to_f
			if amount != 0.0
				name = desc[index..-1].strip
				unit = Unit.search(name)
				raise "can't find unit #{name}" if unit.nil?
				self.unit = unit
				self.unit_amount = amount
			end
		end
		if unit.nil?
			raise "unknown desc #{desc}"
			self.desc = desc
		end
	end
end

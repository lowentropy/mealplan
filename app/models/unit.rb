class Unit < ActiveRecord::Base
	belongs_to :dimension
	has_many :portions
	
	def self.search(name)
		name.downcase!
		find_by_long_name(name) || find_by_short_name(name)
	end

end

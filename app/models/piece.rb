class Piece < ActiveRecord::Base
	has_many :portions
	def self.search(name)
		find_by_name(name.downcase)
	end
end

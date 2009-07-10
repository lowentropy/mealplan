class Modifier < ActiveRecord::Base
	has_and_belongs_to_many :portions
	def self.search(name)
		find_by_name(name.downcase)
	end
end

class Modifier < ActiveRecord::Base
	def self.search(name)
		find_by_name(name.downcase)
	end
end

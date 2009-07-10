class Piece < ActiveRecord::Base
	def self.search(name)
		name = name.singularize unless name =~ /^slice$/i
		find_by_name(name.downcase)
	end
end

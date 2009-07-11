class Food < ActiveRecord::Base
	has_many :food_variants
end

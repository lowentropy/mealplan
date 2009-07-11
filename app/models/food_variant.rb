class FoodVariant < ActiveRecord::Base
	belongs_to :food
	belongs_to :usda_food
	has_and_belongs_to_many :modifiers
end

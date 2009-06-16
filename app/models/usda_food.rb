class UsdaFood < ActiveRecord::Base
	belongs_to :usda_food_group
	has_many :usda_nutrients
	has_many :usda_portions
end

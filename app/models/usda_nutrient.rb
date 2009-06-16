class UsdaNutrient < ActiveRecord::Base
	belongs_to :usda_food
	belongs_to :usda_nutrient_definition
end

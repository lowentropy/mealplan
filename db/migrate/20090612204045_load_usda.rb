class LoadUsda < ActiveRecord::Migration
  def self.up
		%w(food food_group nutrient_definition portion nutrient).each do |source|
			model = "Usda#{source.camelcase}".constantize
			file = "#{RAILS_ROOT}/db/usda/#{source.pluralize}.csv"
			load_usda model, file
		end
  end

  def self.down
		UsdaFood.delete_all
		UsdaFoodGroup.delete_all
		UsdaNutrientDefinition.delete_all
		UsdaPortion.delete_all
		UsdaNutrient.delete_all
  end
end

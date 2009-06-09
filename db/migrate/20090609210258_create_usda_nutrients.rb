class CreateUsdaNutrients < ActiveRecord::Migration
  def self.up
  	create_table :usda_nutrients do |t|
		t.integer :usda_food_id
		t.integer :usda_nutrient_definition_id
		t.float :amount
		t.timestamps
	end
  end

  def self.down
  	drop-table :usda_nutrients
  end
end

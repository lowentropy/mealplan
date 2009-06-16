class CreateUsdaNutrientDefinitions < ActiveRecord::Migration
  def self.up
  	create_table :usda_nutrient_definitions do |t|
			t.integer :unit_id
			t.string :tag
			t.string :desc
			t.string :unit_desc
			t.integer :decimal_places
			t.integer :sort_order
			t.timestamps
		end
  end

  def self.down
  	drop_table :usda_nutrient_definitions
  end
end

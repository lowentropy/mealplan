class AddUsdaIndexes < ActiveRecord::Migration
  def self.up
		change_table :usda_nutrients do |t|
			t.index :usda_nutrient_definition_id
			t.index :usda_food_id
		end
		change_table :usda_portions do |t|
			t.index :usda_food_id
		end
  end

  def self.down
		# can't really hurt anything
  end
end

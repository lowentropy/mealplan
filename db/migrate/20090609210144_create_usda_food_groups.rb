class CreateUsdaFoodGroups < ActiveRecord::Migration
  def self.up
  	create_table :usda_food_groups do |t|
			t.string :desc
			t.timestamps
		end
  end

  def self.down
  	drop_table :usda_food_groups
  end
end

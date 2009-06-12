class CreateUsdaPortions < ActiveRecord::Migration
  def self.up
  	create_table :usda_portions do |t|
			t.integer :usda_food_id
			t.integer :unit_id
			t.string :sequence
			t.float :amount
			t.string :desc
			t.float :grams
			t.timestamps
		end
  end

  def self.down
  	drop_table :usda_portions
  end
end

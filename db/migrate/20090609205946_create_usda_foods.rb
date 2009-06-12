class CreateUsdaFoods < ActiveRecord::Migration
  def self.up
  	create_table :usda_foods do |t|
			t.integer :usda_food_group_id
			t.text :long_desc
			t.string :short_desc
			t.string :common_name
			t.string :manufacturer_name
			t.boolean :survey
			t.string :refuse_desc
			t.integer :refuse_percent
			t.string :scientific_name
			t.float :nitrogen_factor
			t.float :protein_factor
			t.float :fat_factor
			t.float :carb_factor
			t.timestamps
		end
  end

  def self.down
  	drop_table :usda_foods
  end
end

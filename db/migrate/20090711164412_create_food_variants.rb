class CreateFoodVariants < ActiveRecord::Migration
  def self.up
    create_table :food_variants do |t|
      t.integer :food_id
      t.integer :usda_food_id

      t.timestamps
    end
  end

  def self.down
    drop_table :food_variants
  end
end

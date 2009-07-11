class CreateModifiersVariants < ActiveRecord::Migration
  def self.up
		create_table :food_variants_modifiers, :id => false do |t|
			t.integer :modifier_id
			t.integer :food_variant_id
		end
  end

  def self.down
		drop_table :food_variants_modifiers
  end
end

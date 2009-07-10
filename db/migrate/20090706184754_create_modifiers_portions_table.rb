class CreateModifiersPortionsTable < ActiveRecord::Migration
  def self.up
		create_table :modifiers_portions, :id => false do |t|
			t.integer :modifier_id
			t.integer :portion_id
		end
  end

  def self.down
		drop_table :modifiers_portions
  end
end

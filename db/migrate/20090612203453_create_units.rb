class CreateUnits < ActiveRecord::Migration
  def self.up
  	create_table :units do |t|
			t.integer :dimension_id
			t.string :long_name
			t.string :short_name
			t.float :multiplier
			t.timestamps
		end
  end

  def self.down
  	drop_table :units
  end
end

class AddYieldFromToPortions < ActiveRecord::Migration
  def self.up
		change_table :portions do |t|
			t.string :yield_from
		end
  end

  def self.down
		change_table :portions do |t|
			t.remove :yield_from
		end
  end
end

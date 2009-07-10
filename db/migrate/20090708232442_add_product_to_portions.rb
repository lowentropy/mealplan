class AddProductToPortions < ActiveRecord::Migration
  def self.up
		change_table :portions do |t|
			t.string :product
		end
  end

  def self.down
		change_table :portions do |t|
			t.remove :product
		end
  end
end

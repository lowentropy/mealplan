class AddGramsAndYieldsToPortions < ActiveRecord::Migration
  def self.up
		change_table :portions do |t|
			t.float :grams
			t.string :yields
		end
		Portion.all.each do |p|
			p.update_attributes :grams => p.usda_portion.grams
			putc '.'
			$stdout.flush
		end
  end

  def self.down
		change_table :portions do |t|
			t.remove :grams
			t.remove :yields
		end
  end
end

class ParsePortions < ActiveRecord::Migration
  def self.up
		UsdaPortion.all.each do |usda|
			portion = Portion.create :usda_portion_id => usda.id
		end
  end

  def self.down
		Portion.delete_all
  end
end

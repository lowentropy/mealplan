class CreatePortions < ActiveRecord::Migration
  def self.up
    create_table :portions do |t|
      t.integer :usda_portion_id
      t.float :amount
      t.integer :unit_id
      t.float :unit_amount
      t.integer :piece_id
      t.string :desc
      t.boolean :broken

      t.timestamps
    end
  end

  def self.down
    drop_table :portions
  end
end

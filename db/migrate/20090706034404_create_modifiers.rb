class CreateModifiers < ActiveRecord::Migration
  def self.up
    create_table :modifiers do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :modifiers
  end
end

class AddNoteToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :note, :string
  end

  def self.down
    remove_column :readings, :note
  end
end

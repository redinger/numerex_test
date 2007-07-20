 def self.up
    add_column :devices, :modemid, :string, :limit=>30
  end

  def self.down
    remove_column :devices, :modemid
  end
end

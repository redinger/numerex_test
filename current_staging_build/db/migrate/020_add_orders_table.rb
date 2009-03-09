class AddOrdersTable < ActiveRecord::Migration
  def self.up
    create_table "orders", :force => true do |t|
      t.column "account_id", :integer
      t.column "paypal_id", :string, :limit => 50
      t.column "created_at", :datetime
    end
  end

  def self.down
    drop_table "orders"
  end
end

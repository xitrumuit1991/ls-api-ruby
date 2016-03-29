class AddTransidMacToMegabankLogs < ActiveRecord::Migration
  def change
  	add_column :megabank_logs, :mac, :string, after: :user_id
  	add_column :megabank_logs, :transid, :string, after: :user_id
  end
end

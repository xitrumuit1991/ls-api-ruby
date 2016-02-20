class UpdateSmsLogs < ActiveRecord::Migration
  def change
  	remove_foreign_key :sms_logs, :users
    remove_reference :sms_logs, :user, index: true
    rename_column :sms_logs, :checksun, :checksum
    add_column :sms_logs, :active_code, :string, after: :id
  end
end

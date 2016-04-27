class UpdateAndroidReceitp < ActiveRecord::Migration
  def change
  	change_column :android_receipts, :purchaseTime, :bigint
  end
end

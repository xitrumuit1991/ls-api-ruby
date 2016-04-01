class CreateMobifoneUsers < ActiveRecord::Migration
  def change
    create_table :mobifone_users do |t|
      t.string :SubID
      t.string :SenderName
      t.datetime :RegisterTime
      t.string :PartnerID
      t.datetime :LastRegTime
      t.string :RegisterChannel
      t.string :PkgCode
      t.datetime :LastCharged
      t.datetime :LastSuccessCharged
      t.integer :RemainChargeVolume
      t.integer :NextChargeVolume
      t.datetime :NextCharging
      t.integer :FailedRetryCount
      t.datetime :LastCancel
      t.boolean :OldStatus
      t.boolean :Status
      t.boolean :PaidType
      t.boolean :MBF_Status
      t.boolean :IsCharging
      t.float :Point
      t.integer :DayFlag
      t.datetime :BirdDate
      t.string :Password

      t.timestamps null: false
    end
  end
end

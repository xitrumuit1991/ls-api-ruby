class CreateMobifoneBlacklist < ActiveRecord::Migration
  def change
    create_table :mobifone_blacklists, id: false do |t|
      t.primary_key :sub_id, :string, limit: 20
    end
  end
end

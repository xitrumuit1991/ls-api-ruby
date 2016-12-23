class CreateAppConfigs < ActiveRecord::Migration
  def change
    create_table :app_configs do |t|
      t.string :key, limit: 255
      t.string :value, limit: 255

      t.timestamps null: false
    end
  end
end

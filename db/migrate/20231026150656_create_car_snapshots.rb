class CreateCarSnapshots < ActiveRecord::Migration[7.0]
  def change
    create_table :car_snapshots do |t|
      t.datetime :created_at, null: false
      t.string :data
      t.index :created_at
    end
  end
end

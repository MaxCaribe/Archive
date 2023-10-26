class CreateCarSnapshotsArchive < ActiveRecord::Migration[7.0]
  def change
    create_table :car_snapshots_archive do |t|
      t.datetime :created_at, null: false
      t.string :data
      t.index :created_at
    end
  end
end

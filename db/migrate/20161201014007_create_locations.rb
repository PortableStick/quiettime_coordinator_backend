class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :yelp_id
      t.string :center
      t.integer :attending, default: 0

      t.timestamps
    end
  end
end

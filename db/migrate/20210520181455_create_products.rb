class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :product_name
      t.text :descriptio
      t.integer :price
      t.string :vendor

      t.timestamps
    end
  end
end

class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.string :chargeid
      t.string :status
      t.float :amount
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end

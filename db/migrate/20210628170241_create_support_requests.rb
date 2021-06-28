class CreateSupportRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :support_requests do |t|
      t.string :email
      t.string :subject
      t.text :body
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end

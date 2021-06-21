class ChangeCartIdToNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column :line_items, :cart_id, :integer, null: false
  end
end

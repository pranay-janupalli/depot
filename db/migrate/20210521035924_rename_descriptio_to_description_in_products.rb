class RenameDescriptioToDescriptionInProducts < ActiveRecord::Migration[6.1]
  def up
    rename_column :products, :descriptio, :description
  end

  def down
    rename_column :products, :description, :descriptio
  end
end

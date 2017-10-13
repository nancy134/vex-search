class AddNameToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :name, :string
  end
end

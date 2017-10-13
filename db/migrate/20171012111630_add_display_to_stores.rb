class AddDisplayToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :display, :string
  end
end

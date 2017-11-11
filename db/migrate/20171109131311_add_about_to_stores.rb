class AddAboutToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :about, :string
  end
end

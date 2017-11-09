class AddStoreIdToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :store_id, :integer
  end
end

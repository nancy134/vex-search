class AddApplicationIdToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :application_id, :integer
  end
end

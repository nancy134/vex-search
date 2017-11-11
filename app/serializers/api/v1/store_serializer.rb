class Api::V1::StoreSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :display, :about
  def id
    object.store_id
  end
end

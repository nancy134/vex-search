class Api::V1::StoresController < ApplicationController

  def index
    authorization = request.headers['Authorization']
    application = Application.find_by(token: authorization)
    if (application)
      stores = Store.where(application: application.id)
      render json: stores, each_serializer: Api::V1::StoreSerializer
    else
      render json: {message: "Application #{authorization} does not exist"}
    end
  end
end

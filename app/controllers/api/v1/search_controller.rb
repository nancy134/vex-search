class Api::V1::SearchController < ApplicationController
  require 'uri'
  require 'faraday'

  def index
    page = 1
    @array = []
    @url = ""
    @environment = 0 

    # Get URL
    if (params[:staging] == "1")
      @url = "http://ve-api-staging.herokuapp.com"
      @environment = Application.environments["staging"]
    else
      @url = "http://api.vexapps.com"
      @environment = Application.environments["production"]
    end

    @header_authorization = request.headers['Authorization']
    @header_device_token = request.headers['X-Device-Token']
    @header_access_token = request.headers['X-Access-Token']

    @application = Application.find_or_create_by(token: @header_authorization, environment: @environment)

    @stores = Store.where(application_id: @application.id).destroy_all

    #render json: {auth: @header_authorization, device: @header_device_token, access: @header_access_token, environment: @environment, app_token: @application.token, app_id: @application.id}
    #return;
    
    begin
      conn = Faraday.new(:url => @url)
      response = conn.get 'api/stores',
        {:page => page},
        {'Authorization' => @header_authorization,
         'X-Device-Token' => @header_device_token,
         'X-Access-Token' => @header_access_token}
      preorder_subtree(response.body)
      repo_info = JSON.parse(response.body)
      total_pages = repo_info['pages']
      page += 1
    end while page < total_pages
    render json: @array.to_json
  end

  def preorder_subtree(body)
    Rails.logger.debug "preorder_subtree"
    repo_info = JSON.parse(body)

    if (repo_info['pages'] == 0)
      return;
    end

    repo_info['stores'].each do |item|

      name = item['name']

      name_array1 = name.split('<br>')
      if (name_array1.length > 0)
        name = name_array1[0]
        name_array2 = name_array1[0].split('**')
        if (name_array2.length > 2)
          name = name_array2[2]
        end
      end

      if (!item['logo'].include? "medium.png")
        @array << {:name => ActionController::Base.helpers.strip_tags(name), :id => item['id'], :display => name}
        Store.create(id: item['id'], name: ActionController::Base.helpers.strip_tags(name), display: name, application_id: @application.id)
      end


      if (item['stores_count'])
        page = 1
        begin
          conn = Faraday.new(:url => @url)
          id = item['id']
          path = "/api/stores/#{id}/stores"
          response = conn.get path, 
             {:page => page}, 
             {'Authorization' => @header_authorization, 
              'X-Device-Token' => @header_device_token,
              'X-Access-Token' => @header_access_token}
          preorder_subtree(response.body)
          total_pages = repo_info['pages']
          page += 1
        end while page < total_pages
      end
    end
  end
end

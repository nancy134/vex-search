namespace :search do
  task :get_search, [:staging, :authorization, :device_token] => [:environment] do |t, args|
    puts "hello"
    page = 1
    @array = []
    @url = ""
    @environment = 0 

    # Get URL
    if (args[:staging] == "1")
      @url = "http://ve-api-staging.herokuapp.com"
      @environment = Application.environments["staging"]
    else
      @url = "http://api.vexapps.com"
      @environment = Application.environments["production"]
    end

    @header_authorization = "Token token=#{args[:authorization]}" 
    @header_device_token = args[:device_token]

    puts "url: #{@url}"
    puts "header_authorization: #{@header_authorization}"
    puts "header_device_token: #{@header_device_token}"
    @application = Application.find_or_create_by(token: @header_authorization, environment: @environment)

    @stores = Store.where(application_id: @application.id).destroy_all

    begin
      conn = Faraday.new(:url => @url)
      response = conn.get 'api/stores',
        {:page => page},
        {'Authorization' => @header_authorization,
         'X-Device-Token' => @header_device_token}
      preorder_subtree(response.body)
      repo_info = JSON.parse(response.body)
      total_pages = repo_info['pages']
      page += 1
    end while page < total_pages
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
        Store.create(store_id: item['id'], name: ActionController::Base.helpers.strip_tags(name), display: name, application_id: @application.id)
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
              'X-Device-Token' => @header_device_token}
          preorder_subtree(response.body)
          total_pages = repo_info['pages']
          page += 1
        end while page < total_pages
      end
    end
  end
end

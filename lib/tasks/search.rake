namespace :search do
  task :get_search, [:staging, :authorization, :device_token] => [:environment] do |t, args|
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
    repo_info = JSON.parse(body)

    if (repo_info['pages'] == 0)
      return;
    end

    repo_info['stores'].each do |item|

      name = item['name']

      puts "name: #{name}"
      name_array = name.split('**')
      
      if (name_array.length > 2)
        name = name_array[2]
      end

      name_array = name.split('<br>')
      start_br = name.index('<br>')
      
      if (start_br == 0)
        name = name_array[1]
      else
        name = name_array[0]
      end


      if (!item['logo'].include? "medium.png")
        @array << {:name => ActionController::Base.helpers.strip_tags(name), :id => item['id'], :display => name}
        puts "Store #{item['id']}"
        about = item['about'].split("~~")
        display = name
        if (about.length > 1)
          display = "#{name} #{about[1]}"
        end
        Store.create(store_id: item['id'], name: ActionController::Base.helpers.strip_tags(display), display: name, application_id: @application.id, about: item['about'])
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

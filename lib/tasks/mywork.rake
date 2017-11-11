namespace :mywork do
  task xml: :environment do
    Store.all.each do |store|
      about = store.about.split("~~")
      if (about.length > 1)
        puts "num: #{about.length} about: #{about[1]}"
      end
    end
  end
  task nameparse: :environment do

      name = "**14**<br>Real Estate Services"
name = "*05**Shop at<br><font size=4 style=\"color:blue\">Boca Raton</font size><br><font size=-1>Under Construction</font size>"
      puts "name: #{name}"
      name_array = name.split('**')

      puts "name_array.length: #{name_array.length}"      
      if (name_array.length > 2)
        name = name_array[2]
      end
      puts "name: #{name}"

      name_array = name.split('<br>')
      start_br = name.index('<br>')
      puts "name_array.length: #{name_array.length}"
      puts "start_br: #{start_br}"
      
      if (start_br == 0)
        name = name_array[1]
      else 
        name = name_array[0]
      end

      puts "name_array[1]: #{name_array[1]}"
      puts "name: #{name}"
  end
end

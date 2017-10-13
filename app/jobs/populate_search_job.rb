class PopulateSearchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "Populate Search Job"
  end
end

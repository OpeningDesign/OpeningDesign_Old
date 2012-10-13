
# make sure the guest singleton is connected to all projects
begin
  unless Rails.env == 'test'
    Project.all.each do |project|
      unless Activities.instance.connected_to? project
        puts "connecting 'guest' to project #{project}"
        Activities.instance.connect_to(project)
      end
    end
  end
rescue
  puts "

    Error #{$!}

    "
end

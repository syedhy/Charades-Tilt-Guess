require 'xcodeproj'

project_path = '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

def add_file_to_group(project, target, file_path, group_path)
  group = project.main_group
  group_path.split('/').each do |component|
    group = group.children.find { |c| c.display_name == component || c.path == component } || group.new_group(component)
  end

  file_ref = group.new_reference(file_path)
  target.source_build_phase.add_file_reference(file_ref)
  puts "Added #{file_path} to target"
end

add_file_to_group(project, target, 'CharadesTiltGuess/Views/Home/BuyMeACoffeeView.swift', 'CharadesTiltGuess/Views/Home')
add_file_to_group(project, target, 'CharadesTiltGuess/Services/StoreKitManager.swift', 'CharadesTiltGuess/Services')

project.save

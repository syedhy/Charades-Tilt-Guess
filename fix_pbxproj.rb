require 'xcodeproj'

project_path = '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Remove incorrect references
target.source_build_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path && build_file.file_ref.path.include?('CharadesTiltGuess/Views/Home/BuyMeACoffeeView.swift')
    build_file.file_ref.remove_from_project
  elsif build_file.file_ref && build_file.file_ref.path && build_file.file_ref.path.include?('CharadesTiltGuess/Services/StoreKitManager.swift')
    build_file.file_ref.remove_from_project
  end
end

def add_file(project, target, real_path, group_path)
  group = project.main_group
  group_path.split('/').each do |component|
    group = group.children.find { |c| c.display_name == component || c.path == component } || group.new_group(component)
  end

  file_ref = group.new_reference(real_path)
  target.source_build_phase.add_file_reference(file_ref)
  puts "Added #{real_path} to target"
end

add_file(project, target, 'BuyMeACoffeeView.swift', 'CharadesTiltGuess/Views/Home')
add_file(project, target, 'StoreKitManager.swift', 'CharadesTiltGuess/Services')

project.save

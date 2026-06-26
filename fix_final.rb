require 'xcodeproj'

project_path = '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# 1. Remove any reference to the files
target.source_build_phase.files.each do |build_file|
  ref = build_file.file_ref
  if ref && (ref.name == 'BuyMeACoffeeView.swift' || ref.path.to_s.include?('BuyMeACoffeeView.swift') || ref.name == 'StoreKitManager.swift' || ref.path.to_s.include?('StoreKitManager.swift'))
    ref.remove_from_project
  end
end

# 2. Recreate groups if needed and add files using set_path
def add_file(project, target, file_name, group_path)
  group = project.main_group
  group_path.split('/').each do |component|
    group = group.children.find { |c| c.display_name == component || c.path == component } || group.new_group(component)
  end
  file_ref = group.new_reference(file_name)
  target.source_build_phase.add_file_reference(file_ref)
end

add_file(project, target, 'BuyMeACoffeeView.swift', 'CharadesTiltGuess/Views/Home')
add_file(project, target, 'StoreKitManager.swift', 'CharadesTiltGuess/Services')

project.save

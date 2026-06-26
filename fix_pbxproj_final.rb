require 'xcodeproj'

project_path = '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Remove ALL references to these files by name anywhere
target.source_build_phase.files.each do |build_file|
  ref = build_file.file_ref
  if ref && (ref.name == 'BuyMeACoffeeView.swift' || ref.path.to_s.include?('BuyMeACoffeeView.swift') || ref.name == 'StoreKitManager.swift' || ref.path.to_s.include?('StoreKitManager.swift'))
    puts "Removing #{ref.path}"
    ref.remove_from_project
  end
end

def add_file(project, target, absolute_path, group_path)
  group = project.main_group
  group_path.split('/').each do |component|
    group = group.children.find { |c| c.display_name == component || c.path == component } || group.new_group(component)
  end

  # Create reference and force path to be absolute or relative to group
  file_ref = group.new_reference(absolute_path)
  target.source_build_phase.add_file_reference(file_ref)
  puts "Added #{absolute_path} to target"
end

add_file(project, target, '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess/Views/Home/BuyMeACoffeeView.swift', 'CharadesTiltGuess/Views/Home')
add_file(project, target, '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess/Services/StoreKitManager.swift', 'CharadesTiltGuess/Services')

project.save

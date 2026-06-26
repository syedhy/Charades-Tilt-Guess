require 'xcodeproj'

project_path = '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# We want to remove the ones where path does not include 'CharadesTiltGuess/'
target.source_build_phase.files.each do |build_file|
  ref = build_file.file_ref
  if ref && (ref.name == 'BuyMeACoffeeView.swift' || ref.path == 'BuyMeACoffeeView.swift' || ref.name == 'StoreKitManager.swift' || ref.path == 'StoreKitManager.swift')
    if !ref.path.include?('CharadesTiltGuess/')
      puts "Removing bad ref: #{ref.path}"
      ref.remove_from_project
    end
  end
end

project.save

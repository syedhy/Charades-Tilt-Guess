require 'xcodeproj'

project_path = '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

def add_file_to_group(project, target, file_path, group_path)
  group = project.main_group.find_subpath(group_path, true)
  file_ref = group.new_reference(file_path)
  # Check if it's already in the build phase
  unless target.source_build_phase.files_references.include?(file_ref)
    target.source_build_phase.add_file_reference(file_ref)
  end
end

add_file_to_group(project, target, 'TeamMatchState.swift', 'CharadesTiltGuess/Models')
add_file_to_group(project, target, 'TeamMatchSelectionView.swift', 'CharadesTiltGuess/Views/Home')
add_file_to_group(project, target, 'TeamMatchLobbyView.swift', 'CharadesTiltGuess/Views/Game')
add_file_to_group(project, target, 'TeamMatchResultsView.swift', 'CharadesTiltGuess/Views/Game')

project.save
puts "Files added successfully."

require 'xcodeproj'

project_path = '/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Remove DE75D1F1146CA1B2904882E8 specifically
obj = project.objects_by_uuid['DE75D1F1146CA1B2904882E8']
if obj
  obj.remove_from_project
  puts "Removed DE75D1F1146CA1B2904882E8"
end

project.save

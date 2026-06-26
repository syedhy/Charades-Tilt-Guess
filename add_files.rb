require 'xcodeproj'
project_path = 'CharadesTiltGuess.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.find_subpath(File.join('CharadesTiltGuess', 'Views', 'Onboarding'), true)

file1 = group.new_file('OnboardingSplashView.swift')
target.source_build_phase.add_file_reference(file1)

file2 = group.new_file('OnboardingCoordinatorView.swift')
target.source_build_phase.add_file_reference(file2)

project.save

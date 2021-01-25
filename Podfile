platform :ios, '14.0'

def common_pods

  pod 'R.swift'
  pod 'SwiftLint'

end

target 'Space' do

  use_frameworks!

  common_pods

  target 'SpaceTests' do
    inherit! :search_paths
  end

end

target 'SpaceWidgetExtension' do

  use_frameworks!

  common_pods

end

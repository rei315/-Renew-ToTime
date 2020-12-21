# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!

target 'ToTime' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ToTime
pod 'RxSwift'
pod 'RxCocoa'
pod 'Action'
pod 'RxDataSources'
pod 'RxGesture'

pod 'RxCoreLocation'

pod 'Alamofire'

pod 'SnapKit'

pod 'RealmSwift', '~> 10.2'

pod 'GoogleMaps'
pod 'RxGoogleMaps'

  target 'ToTimeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ToTimeUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

platform :ios, '15.5'

target 'DraPla05' do
  # Comment the next line if you don't want to use dynamic frameworks
  #use_frameworks!
  use_modular_headers!

  pod 'FloatingPanel', '1.7.6'
  pod 'RealmSwift'
  pod 'DKImagePickerController'
  pod 'SideMenu', '~> 6.0'

  pod 'Material'
  pod 'CropViewController'
  pod 'R.swift'
  pod 'SwipeCellKit'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'

  pod 'IQKeyboardManagerSwift'
  pod 'SnapKit', '~> 5.0.0'
  pod 'Motion', '~> 3.1.0'
  pod 'IGListKit', '~> 4.0.0'
  pod 'SwiftyStoreKit'
  pod 'Alertift', '~> 4.1'
  pod "KRProgressHUD"
  
  # Pods for DraPla05
  
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end

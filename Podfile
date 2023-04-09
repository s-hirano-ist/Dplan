platform :ios, '16.2'

target 'Dplan' do
  # Comment the next line if you don't want to use dynamic frameworks
  #use_frameworks!
  use_modular_headers!

  pod 'DKImagePickerController', '~> 4.3.4'
  pod 'FloatingPanel', '~> 1.7.6'
  pod 'RealmSwift', '~> 10.33.0'
  pod 'SideMenu', '~> 6.0'

  pod 'Material', '~> 3.1.0'
  pod 'CropViewController'
  pod 'R.swift', '~> 7.3.0'
  pod 'SwipeCellKit', '~> 2.7.1'
  pod 'RxSwift', '~> 6.5.0'
  pod 'RxCocoa', '~> 6.5.0'

  pod 'IQKeyboardManagerSwift', '~> 6.5.10'
  pod 'SnapKit', '~> 5.6.0'
  pod 'Motion', '~> 3.1.0'
  pod 'IGListKit', '~> 4.0.0'
  pod "KRProgressHUD", '~> 3.4'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end
end

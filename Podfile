source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

xcodeproj 'Standout.xcodeproj'
use_frameworks!

pod 'Reachability', '~> 3.2'
pod 'MBProgressHUD', '~> 0.9'
pod 'PonyDebugger', '~> 0.4.0'
pod 'TSMessages'
pod 'FontAwesomeKit'
pod 'SimpleAuth/FacebookWeb'
pod 'SimpleAuth/TwitterWeb'
pod 'SimpleAuth/Instagram'
pod 'SimpleAuth/Tumblr'
pod 'TTTAttributedLabel'
pod 'DBCamera'
pod 'libPhoneNumber-iOS'
pod 'JazzHands'
pod 'Lookback', :configurations => ['Debug']
pod 'LookbackSafe', :configurations => ['Release']
pod 'SDWebImage'
pod 'YLProgressBar'
pod 'iOS-blur'
pod 'AFNetworking'
pod 'Mantle'
pod 'RNFrostedSidebar'
pod 'pop', '~> 1.0'
pod 'PINCache'
#pod 'Parse+NSCoding'
pod 'Advance', '~> 0.9'
pod 'Bugsnag'
pod 'Bolts'
#pod 'Facebook-iOS-SDK', '3.21.0'
#pod 'Facebook-iOS-SDK', '4.10.0'
pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'
pod 'OneSignal'
pod 'ParseFacebookUtilsV4'
pod "TSMessages"
pod 'TBActionSheet'

post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end

#
# Be sure to run `pod lib lint JJGuiso.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JJGuiso'
  s.version          = '1.8.3'
  s.summary          = 'Easy way to load images and Animated Images.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Guiso is image loading framework for IOS that wraps media decoding, memory and disk caching. By default Guiso uses URLSession.
                       DESC

  s.homepage         = 'https://github.com/Only-IceSoul/Guiso'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author           = { 'only-icesoul' => 'justinjlf21@gmail.com' }
  s.source           = { :git => 'https://github.com/Only-IceSoul/Guiso.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
 

  s.ios.deployment_target = '11.0'

  s.source_files = ['src/**/*.swift']
  s.swift_version = '5.0'
  s.platforms = {
      "ios": "11.0"
  }

  s.vendored_frameworks = 'Frameworks/*.framework'

  # comment arm64 for xcode 11 if any error
  s.pod_target_xcconfig = { 'ARCHS'  => '$(ARCHS_STANDARD)' ,
 'ONLY_ACTIVE_ARCH' => 'YES'}
  s.user_target_xcconfig = { 'ARCHS'  => '$(ARCHS_STANDARD)', 'ONLY_ACTIVE_ARCH' => 'YES'}
#  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
#  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  # s.resource_bundles = {
  #   'JJGuiso' => ['JJGuiso/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

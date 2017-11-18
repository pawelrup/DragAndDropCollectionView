#
# Be sure to run `pod lib lint DragAndDropCollectionView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DragAndDropCollectionView'
  s.version          = '0.1.2'
  s.summary          = 'DragAndDropCollectionView is an extended UICollectionView from which you can drag and drop cells.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
DragAndDropCollectionView is an extended UICollectionView from which you can drag and drop cells.
Requires Xcode 9 with Swift 4.0
                       DESC

  s.requires_arc = true
  s.homepage         = 'https://github.com/pawelrup/DragAndDropCollectionView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Paweł Rup' => 'pawelrup@lobocode.pl' }
  s.source           = { :git => 'https://github.com/pawelrup/DragAndDropCollectionView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DragAndDropCollectionView/Classes/**/*'
  s.pod_target_xcconfig =  {
      'SWIFT_VERSION' => '4.0',
  }
  
  # s.resource_bundles = {
  #   'DragAndDropCollectionView' => ['DragAndDropCollectionView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

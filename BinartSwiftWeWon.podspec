#
# Be sure to run `pod lib lint BinartSwiftWeWon.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BinartSwiftWeWon'
  s.version          = '0.3.1'
  s.summary          = 'Swift app dependencies.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Swift app dependencies: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/fallending/BinartSwiftWeWon-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fallending' => 'fengzilijie@qq.com' }
  s.source           = { :git => 'https://github.com/fallending/BinartSwiftWeWon-iOS.git', :tag => s.version.to_s }
  s.source_files     = 'BinartSwiftWeWon/Classes/**/*.swift'

  s.requires_arc     = true
  s.swift_version    = '5.0'

  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig   = {
      "SWIFT_VERSION" => "5.0",
  }

  s.dependency 'HandyJSON'
  s.dependency 'GKNavigationBarSwift'
  s.dependency 'Kingfisher'
end

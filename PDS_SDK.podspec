#
# Be sure to run `pod lib lint pds-sdk-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PDS_SDK'
  s.version          = '0.0.2'
  s.summary          = '阿里云相册与网盘服务Objc SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  PDS iOS客户端SDK
                       DESC

  s.homepage         = 'https://github.com/aliyun/aliyun-pds-objc-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aliyun Open Service' => 'aliyuncloudcomputing' }
  s.source           = { :git => 'https://github.com/aliyun/aliyun-pds-objc-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'pds-sdk-objc/Classes/**/*'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES'}
  s.public_header_files = 'pds-sdk-objc/Classes/**/*.h'
#  s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'FMDB', '~> 2.7'
  s.dependency 'extobjc'
  s.dependency 'YYModel'
end

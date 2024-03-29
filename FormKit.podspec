#
# Be sure to run `pod lib lint FormKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FormKit'
  s.version          = '0.1.0'
  s.summary          = 'A Library to make Forms'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Using UITableView this will allow you to easily create forms with different types of inputs.
                       DESC

  s.homepage         = 'https://github.com/jmade/FormKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Justin Madewell' => 'justinmadewell@me.com' }
  s.source           = { :git => 'https://github.com/jmade/FormKit.git', :tag => s.version.to_s }


  s.ios.deployment_target = '12.0'

  s.source_files = 'FormKit/Classes/**/*', 'Classes', 'Classes/**/*'
  
  # s.resource_bundles = {
  #   'FormKit' => ['FormKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

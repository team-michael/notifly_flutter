#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'notifly_flutter_ios'
  s.version          = '1.11.0'
  s.summary          = 'An iOS implementation of the notifly_flutter plugin.'
  s.description      = <<-DESC
  An iOS implementation of the notifly_flutter plugin.
                       DESC
  s.homepage         = 'http://notifly.tech/'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Grey Box Inc.' => 'team@greyboxhq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'notifly_sdk', '1.17.0'
end

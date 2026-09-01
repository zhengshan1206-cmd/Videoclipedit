Pod::Spec.new do |s|
  s.name             = 'bda_signal'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin for BDA Signal SDK.'
  s.description      = <<-DESC
A new Flutter plugin for BDA Signal SDK.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'BDASignalSDK'
  s.platform         = :ios, '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.0'
end 
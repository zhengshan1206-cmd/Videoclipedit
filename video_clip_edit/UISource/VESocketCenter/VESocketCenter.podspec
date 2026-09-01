Pod::Spec.new do |spec|

  spec.name         = "VESocketCenter"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of VESocketCenter."
  spec.homepage     = "http://EXAMPLE/VESocketCenter"
  spec.ios.deployment_target  = '9.0'
  spec.license      = "MIT"
  spec.author       = { "iOS VESDK Team" => "" }
  spec.user_target_xcconfig = {'ALWAYS_SEARCH_USER_PATHS'=>'YES' }
  #远程push的写法
  spec.source       = { :path => '.' }
  spec.source_files  = '**/*.{h}'
  spec.vendored_frameworks = '**/VESocketCenter.framework'
  spec.requires_arc = true
  spec.swift_version = "5.0"
  
end

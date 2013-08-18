Pod::Spec.new do |s|
  s.name         = "ObjcNetworking"
  s.version      = "0.0.1"
  s.summary      = "Simple and lightweight objective-c http-networking library."
  s.homepage     = "https://github.com/styrken/objc-networking"
  s.license      = 'MIT'
  s.author       = { "Rasmus Theodor Styrk" => "styrken@gmail.com" }
  s.platform     = :ios
  s.osx.deployment_target = '10.7'
  s.source       = { :git => "https://github.com/styrken/objc-networking.git", :tag => '1.0.1' }
  s.source_files  = 'src'
  s.exclude_files = ''
end

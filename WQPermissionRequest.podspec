
Pod::Spec.new do |s|
  s.name          = "WQPermissionRequest"
  s.version       = "1.0.0"
  s.summary       = "A permission request framework"
  s.description   = <<-DESC
  If you are the first request a permission，the framework will call the system function to request for you.
  And,if you are not the first request,it will be give you note to open the permission
                   DESC

  s.homepage      = "https://github.com/AppleDP/WQPermissionRequest"
  s.license       = "MIT"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "AppleDP" => "AppleDP@163.com" }
  s.requires_arc  = true
  s.platform      = :ios,'8.0'
  s.source        = { :git => "https://github.com/AppleDP/WQPermissionRequest.git", :tag => s.version }
  s.source_files  = "WQPermissionRequest/**/WQPermissionRequest/*"
end
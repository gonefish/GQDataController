Pod::Spec.new do |s|
  s.name         = "GQDataController"
  s.version      = "0.0.1"
  s.summary      = "结合AFNetworking和Mantle的接口请求封装"

  s.description  = <<-DESC
                   封装AFNetworking和Mantle的MVVM实
                   通过GQDataController进行视图的属性绑定
                   DESC

  s.homepage     = "https://github.com/gonefish/GQDataController"
  s.platform     = :ios, "7.0"
  s.license      = "MIT"
  s.author       = { "Qian GuoQiang" => "gonefish@gmail.com" }
  s.source       = { :git => "https://github.com/gonefish/GQDataController.git", :tag => s.version.to_s }

  s.source_files  = "GQDataController*.{h,m}"

  s.dependency 'AFNetworking', '~> 2.5.4'
  s.dependency 'Mantle', '~>1.5.4'
  s.dependency 'FormatterKit/URLRequestFormatter', '~> 1.8.0'
end

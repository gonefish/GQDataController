Pod::Spec.new do |s|
  s.name         = "GQDataController"
  s.version      = "0.8"
  s.summary      = "A networking framework for MVVM in iOS"

  s.description  = <<-DESC
                   一款符合MVVM模式的网络框架，通过混合AFNetworking和Mantle让你更方便的处理网络交互。
                   DESC

  s.homepage     = "https://github.com/gonefish/GQDataController"
  s.platform     = :ios, "8.0"
  s.license      = "MIT"
  s.author       = { "Qian GuoQiang" => "gonefish@gmail.com" }
  s.source       = { :git => "https://github.com/gonefish/GQDataController.git", :tag => s.version.to_s }
  s.default_subspec = 'Default'

  s.subspec 'Core' do |core|

  	core.dependency 'AFNetworking', '~> 3.0'
  	core.dependency 'OHHTTPStubs', '>= 4.0'
    core.source_files = 'GQDataController/*.{h,m}'

  end

  s.subspec 'Default' do |default|

  	default.dependency 'GQDataController/Core'
    default.source_files = 'GQDataController/Adapter/GQDefaultAdapter.{h,m}'

  end

  s.subspec 'Mantle' do |mantle|

    mantle.dependency 'Mantle', '~> 2.0'
    mantle.dependency 'GQDataController/Core'
    s.source_files = 'GQDataController/Adapter/GQMantleAdapter.{h,m}'

  end

end

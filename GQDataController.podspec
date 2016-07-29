Pod::Spec.new do |s|
  s.name         = "GQDataController"
  s.version      = "1.1"
  s.summary      = "A networking framework for MVVM in iOS"

  s.description  = <<-DESC
                   一款符合MVVM模式的网络框架，通过混合AFNetworking和Mantle让你更方便的处理网络交互。
                   DESC

  s.homepage     = "https://github.com/gonefish/GQDataController"
  s.platform     = :ios, "7.0"
  s.license      = "MIT"
  s.author       = { "Qian GuoQiang" => "gonefish@gmail.com" }
  s.source       = { :git => "https://github.com/gonefish/GQDataController.git", :tag => s.version.to_s }
  s.default_subspec = 'Default'

  s.subspec 'Default' do |default|

    default.dependency 'AFNetworking', '~> 3.0'
    default.source_files = 'GQDataController/*.{h,m}', 'GQDataController/Adapter/GQDefaultAdapter.{h,m}'

  end

  s.subspec 'Mantle' do |mantle|

    mantle.dependency 'Mantle'
    mantle.dependency 'GQDataController/Default'
    mantle.source_files = 'GQDataController/Adapter/GQMantleAdapter.{h,m}'

  end

  s.subspec 'YYModel' do |yymodel|

    yymodel.dependency 'YYModel'
    yymodel.dependency 'GQDataController/Default'
    yymodel.source_files = 'GQDataController/Adapter/GQYYModelAdapter.{h,m}'

  end

  s.subspec 'YYKit' do |yykit|

    yykit.dependency 'YYKit'
    yykit.dependency 'GQDataController/Default'
    yykit.source_files = 'GQDataController/Adapter/GQYYModelAdapter.{h,m}'

  end

  s.subspec 'JSONModel' do |jsonmodel|

    jsonmodel.dependency 'JSONModel'
    jsonmodel.dependency 'GQDataController/Default'
    jsonmodel.source_files = 'GQDataController/Adapter/GQJSONModelAdapter.{h,m}'

  end

  s.subspec 'MJExtension' do |mjextension|

    mjextension.dependency 'MJExtension'
    mjextension.dependency 'GQDataController/Default'
    mjextension.source_files = 'GQDataController/Adapter/GQMJExtensionAdapter.{h,m}'

  end

end

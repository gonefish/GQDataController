Pod::Spec.new do |s|
  s.name         = "GQDataController"
  s.version      = "0.0.1"
  s.summary      = "A short description of GQDataController."

  s.description  = <<-DESC
                   A longer description of GQDataController in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/gonefish/GQDataController"
  s.platform     = :ios, "7.0"
  s.author       = { "Qian GuoQiang" => "gonefish@gmail.com" }
  s.source       = { :git => "https://github.com/gonefish/GQDataController.git", :tag => s.version.to_s }

  s.source_files  = "GQDataController*.{h,m}"

  s.dependency 'AFNetworking', '~> 2.5.4'
  s.dependency 'FormatterKit/URLRequestFormatter', '~> 1.8.0'
end

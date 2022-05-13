# react-native-minml-prediction-engine.podspec

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-minml-prediction-engine"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-minml-prediction-engine
                   DESC
  s.homepage     = "https://github.com/vipintom/react-native-minml-prediction-engine"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Vipin Tom Varghese" => "vipin@minml.ai" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/vipintom/react-native-minml-prediction-engine.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,cc,cpp,m,mm,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency 'TensorFlowLiteSwift', '~> 0.0.1-nightly'
  # ...
  # s.dependency "..."
end


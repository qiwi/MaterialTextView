Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.name = 'MaterialTextView'
  s.summary = 'Implementation of text field/view for iOS according to Material Design'
  s.requires_arc = true
  s.version = '1.0'
  s.license = { :type => 'MIT' }
  s.author   = { 'QIWI Wallet' => 'iphone@qiwi.com' }
  s.homepage = 'https://github.com/qiwi'
  s.source = { :git => 'https://github.com/qiwi/MaterialTextView' }
  s.framework = "UIKit"
  s.source_files = 'MaterialTextView/*.swift'
  s.dependency 'https://github.com/qiwi/FormattableTextView'
end
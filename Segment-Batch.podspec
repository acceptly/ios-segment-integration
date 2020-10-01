Pod::Spec.new do |s|
  s.name             = 'Segment-Batch'
  s.version          = '1.2.0'
  s.summary          = "Batch.com Integration for Segment's analytics-ios library."

  s.description      = <<-DESC
                       This is the Batch.com SDK integration for the iOS Segment library.
                       DESC

  s.homepage         = 'https://batch.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Batch.com' => 'support@batch.com' }
  s.source           = { :git => 'https://github.com/BatchLabs/ios-segment-integration.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.static_framework = true
  
  s.dependency 'Analytics', '~> 4.0'
  s.default_subspec = 'Standard'

  s.subspec 'Standard' do |std|
    std.source_files = 'Pod/Classes/**/*'
    std.dependency 'Batch', '~> 1.13'
  end
end

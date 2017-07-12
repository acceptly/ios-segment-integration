Pod::Spec.new do |s|
  s.name             = 'Segment-Batch'
  s.version          = '1.0.0'
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
  
  s.dependency 'Analytics', '~> 3.0.0'
  s.default_subspec = 'Standard'

  s.subspec 'Standard' do |std|
    std.source_files = 'Pod/Classes/**/*'
    std.dependency 'Batch', '~> 1.9'
  end

  s.subspec 'StaticLibWorkaround' do |workaround|
    # Exactly like https://github.com/segment-integrations/analytics-ios-integration-google-analytics/blob/master/Segment-GoogleAnalytics.podspec
    # For users who are unable to bundle static libraries as dependencies
    # you can choose this subspec, but be sure to include the following in your Podfile:
    # pod 'Batch'
    # Please manually add the following files preserved by Cocoapods to your xcodeproj file
    workaround.preserve_paths = 'Pod/Classes/**/*'
  end
end

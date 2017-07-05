# Batch Segment Integration

[![Version](https://img.shields.io/cocoapods/v/Segment-google-analytics.svg?style=flat)](http://cocoapods.org/pods/Segment-batch)
[![License](https://img.shields.io/cocoapods/l/Segment-google-analytics.svg?style=flat)](http://cocoapods.org/pods/Segment-batch)

Batch.com integration for analytics-ios.

## Installation

To install the Segment-Batch Analytics integration, simply add this line to your [CocoaPods](http://cocoapods.org) `Podfile`:

```ruby
pod 'Segment-Batch'
```

## Usage

After adding the dependency, you must register the integration with our SDK.  To do this, import the Google Analytics integration in your `AppDelegate`:

```objc
#import <Segment-Batch/SEGBatchIntegrationFactory.h>
```

And add the following lines:

```objc
SEGAnalyticsConfiguration *config = [SEGAnalyticsConfiguration configurationWithWriteKey:@"MySegmentWriteKey"];
[config use:[SEGBatchIntegrationFactory instance]];
[SEGAnalytics setupWithConfiguration:config];
```

### Workaround for projects unable to use the static library

If you've got a Swift project or simply require "use_frameworks!" in your Podfile, you will not be able to use the standard pod.

You will need to use the "StaticLibWorkaround" subspec, and add Batch as a dependency.  

Your podfile should look like:  

```ruby
pod 'Batch'
pod 'Segment-Batch/StaticLibWorkaround'
```

You'll also need to change your import:  

```objc
#import "SEGBatchIntegrationFactory.h"
```

## Disabling configuration and start handling

If you'd like to disable the remote configuration and control yourself Batch's settings and when startWithApiKey is called, you can tell the segment integration to only worry about Analytics:

```objc
SEGBatchIntegrationFactory.enableAutomaticStart = false;
```


Note: This is required for some features like the [manual integration](https://batch.com/doc/ios/advanced/manual-integration.html)
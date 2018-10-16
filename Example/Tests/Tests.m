// https://github.com/Specta/Specta

#import <Batch/Batch.h>

#import <Segment-Batch/SEGBatchIntegration.h>

SpecBegin(IntegrationSpecs)

void (^waitForMainThreadLoop)(XCTestCase*) = ^(XCTestCase* testCase){
    // Since the integration schedules async work on the main thread, we have
    // to perform a little dance to correctly test the behaviour
    // To work around this, we schedule something to run on the main thread
    // AFTER other work has been submitted, and wait for our dummy
    // task to finish
    XCTestExpectation *expectation = [testCase expectationWithDescription:@"Wait for a main thread loop run"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [testCase waitForExpectations:@[expectation] timeout:3.0];
};

describe(@"Batch's segment integration", ^{

    __block id batchUserMock;
    __block id batchUserDataEditorMock;
    
    SEGBatchIntegration *integration = [SEGBatchIntegration new];
    
    beforeEach(^{
        batchUserDataEditorMock = OCMClassMock([BatchUserDataEditor class]);
        
        batchUserMock = OCMClassMock([BatchUser class]);
    });
    
    it(@"can track a 'track' call", ^{
        [batchUserMock setExpectationOrderMatters:YES];
        
        OCMExpect([batchUserMock trackEvent:@"TEST_EVENT" withLabel:@"label"]);
        OCMExpect([batchUserMock trackEvent:@"TEST_EVENT_TOO_LONG_AAAAAAAAAA" withLabel:[OCMArg isNil]]);
        OCMExpect([batchUserMock trackEvent:@"TEST_TRANSACTION" withLabel:[OCMArg isNil]]);
        OCMExpect([batchUserMock trackTransactionWithAmount:1.234500]);
        OCMExpect([batchUserMock trackEvent:@"TEST_TRANSACTION" withLabel:[OCMArg isNil]]);
        OCMExpect([batchUserMock trackTransactionWithAmount:1.234600]);
        OCMExpect([batchUserMock trackEvent:@"TEST_TRANSACTION" withLabel:[OCMArg isNil]]);
        OCMExpect([batchUserMock trackTransactionWithAmount:1.234700]);
        
        
        SEGTrackPayload *p = [[SEGTrackPayload alloc] initWithEvent:@"TEST_EVENT"
                                                         properties:@{@"title": @"label"}
                                                            context:@{}
                                                       integrations:@{}];
        [integration track:p];
        
        p = [[SEGTrackPayload alloc] initWithEvent:@"Test Event Too Long_Aaaaaaaaaaaaaaaaaaaa"
                                        properties:@{}
                                           context:@{}
                                      integrations:@{}];
        [integration track:p];
        
        p = [[SEGTrackPayload alloc] initWithEvent:@"TEST_TRANSACTION"
                                        properties:@{@"total": @(1.2345)}
                                           context:@{}
                                      integrations:@{}];
        [integration track:p];
        
        p = [[SEGTrackPayload alloc] initWithEvent:@"TEST_TRANSACTION"
                                        properties:@{@"revenue": @(1.2346)}
                                           context:@{}
                                      integrations:@{}];
        [integration track:p];
        
        p = [[SEGTrackPayload alloc] initWithEvent:@"TEST_TRANSACTION"
                                        properties:@{@"value": @(1.2347)}
                                           context:@{}
                                      integrations:@{}];
        [integration track:p];
        
        OCMVerifyAll(batchUserMock);
    });

    it(@"can track a 'screen' call", ^{
        OCMExpect([batchUserMock trackEvent:@"SEGMENT_SCREEN" withLabel:@"Foo"]);
        
        [integration screen:[[SEGScreenPayload alloc] initWithName:@"Foo"
                                                        properties:@{}
                                                           context:@{}
                                                      integrations:@{}]];
        
        OCMVerifyAll(batchUserMock);
    });
    
    it(@"can save the groupId as an attribute", ^{
        [batchUserDataEditorMock setExpectationOrderMatters:YES];
        OCMExpect([batchUserMock editor]).andReturn(batchUserDataEditorMock);
        OCMExpect([batchUserDataEditorMock setAttribute:@"foo" forKey:@"SEGMENT_GROUP"]);
        OCMExpect([batchUserDataEditorMock save]);
        
        [integration group:[[SEGGroupPayload alloc] initWithGroupId:@"foo"
                                                             traits:@{}
                                                            context:@{}
                                                       integrations:@{}]];
        
        OCMVerifyAll(batchUserMock);
        OCMVerifyAll(batchUserDataEditorMock);
    });
    
    it(@"can identify", ^{
        [batchUserDataEditorMock setExpectationOrderMatters:YES];
        OCMExpect([batchUserMock editor]).andReturn(batchUserDataEditorMock);
        OCMExpect([batchUserDataEditorMock setIdentifier:@"userId"]);
        OCMExpect([batchUserDataEditorMock save]);
        OCMExpect([batchUserMock editor]).andReturn(batchUserDataEditorMock);
        OCMExpect([batchUserDataEditorMock setIdentifier:[OCMArg isNil]]);
        OCMExpect([batchUserDataEditorMock save]);
        
        [integration identify:[[SEGIdentifyPayload alloc] initWithUserId:@"userId"
                                                             anonymousId:@"anonId"
                                                                  traits:@{}
                                                                 context:@{}
                                                            integrations:@{}]];
        
        [integration identify:[[SEGIdentifyPayload alloc] initWithUserId:nil
                                                             anonymousId:@"anonId"
                                                                  traits:@{}
                                                                 context:@{}
                                                            integrations:@{}]];
        
        OCMVerifyAll(batchUserMock);
        OCMVerifyAll(batchUserDataEditorMock);
    });
    
    it(@"can reset", ^{
        [batchUserDataEditorMock setExpectationOrderMatters:YES];
        OCMExpect([batchUserMock editor]).andReturn(batchUserDataEditorMock);
        OCMExpect([batchUserDataEditorMock setIdentifier:[OCMArg isNil]]);
        OCMExpect([batchUserDataEditorMock clearTags]);
        OCMExpect([batchUserDataEditorMock clearAttributes]);
        OCMExpect([batchUserDataEditorMock save]);
        
        [integration reset];
        
        OCMVerifyAll(batchUserMock);
        OCMVerifyAll(batchUserDataEditorMock);
    });
});

describe(@"Batch's integration factory", ^{

    __block id batchMock;
    
    beforeEach(^{
        batchMock = OCMClassMock([Batch class]);
        SEGBatchIntegration.enableAutomaticStart = YES;
    });
    
    it(@"can start Batch", ^{
        [batchMock setExpectationOrderMatters:YES];
        OCMExpect([batchMock setUseIDFA:NO]);
        OCMExpect([batchMock setUseAdvancedDeviceInformation:NO]);
        OCMExpect([batchMock startWithAPIKey:@"foo"]);
        
        
        NSDictionary *settings = @{
                                   @"apiKey": @"foo",
                                   @"canUseAdvertisingID": @(false),
                                   @"canUseAdvancedDeviceInformation": @(false)
                                   };
        
        [SEGBatchIntegration startWithSettings:settings];
        
        waitForMainThreadLoop(self);
        
        OCMVerifyAll(batchMock);
    });
    
    it(@"does not start batch if the API key is missing", ^{
        OCMReject([batchMock setUseIDFA:[OCMArg any]]);
        OCMReject([batchMock setUseAdvancedDeviceInformation:[OCMArg any]]);
        OCMReject([batchMock startWithAPIKey:[OCMArg any]]);
        
        
        NSDictionary *settings = @{
                                   @"apiKey": @"",
                                   @"canUseAdvertisingID": @(false),
                                   @"canUseAdvancedDeviceInformation": @(false)
                                   };
        
        [SEGBatchIntegration startWithSettings:settings];
        
        OCMVerifyAll(batchMock);
    });
    
    it(@"does not start batch if automatic start is disabled", ^{
        SEGBatchIntegration.enableAutomaticStart = NO;
        OCMReject([batchMock setUseIDFA:[OCMArg any]]);
        OCMReject([batchMock setUseAdvancedDeviceInformation:[OCMArg any]]);
        OCMReject([batchMock startWithAPIKey:[OCMArg any]]);
        
        
        NSDictionary *settings = @{
                                   @"apiKey": @"foo",
                                   @"canUseAdvertisingID": @(false),
                                   @"canUseAdvancedDeviceInformation": @(false)
                                   };
        
        [SEGBatchIntegration startWithSettings:settings];
        
        OCMVerifyAll(batchMock);
    });
    
    it(@"sets the plugin identification env var", ^{
        XCTAssertTrue(getenv("BATCH_PLUGIN_VERSION") != NULL);
    });
    
    it(@"saves its settings", ^{
        id userDefaults = OCMClassMock([NSUserDefaults class]);
        OCMStub([userDefaults standardUserDefaults]).andReturn(userDefaults);
        [SEGBatchIntegration saveSettings:@{}];
        
        waitForMainThreadLoop(self);
        
        OCMVerify([userDefaults setObject:[OCMArg isNotNil] forKey:@"SEGBatchIntegrationSettings"]);
    });
    
    it(@"restores its settings on start", ^{
        id userDefaults = OCMClassMock([NSUserDefaults class]);
        OCMStub([userDefaults standardUserDefaults]).andReturn(userDefaults);
        OCMExpect([userDefaults valueForKey:@"SEGBatchIntegrationSettings"]).andReturn(@{
                                                                                         @"apiKey": @"foobar"
                                                                                         });
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification
                                                            object:nil];
        
        waitForMainThreadLoop(self);
        
        OCMVerifyAll(userDefaults);
        OCMVerify([batchMock startWithAPIKey:@"foobar"]);
    });
});

SpecEnd

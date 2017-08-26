//
//  movies_embeddedTests.m
//  movies_embeddedTests
//
//  Created by Jerry Hale on 8/25/17.
//  Copyright © 2017 jhale. All rights reserved.
//

@import EarlGrey;

#import <XCTest/XCTest.h>

@interface movies_embeddedTests : XCTestCase

@end

@implementation movies_embeddedTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_tapMarqueeView
{
	//	just tap on the Marquee
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(@"marqueeView")]
      performAction:grey_tap()];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

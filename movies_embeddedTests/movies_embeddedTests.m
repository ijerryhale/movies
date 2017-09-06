//
//  movies_embeddedTests.m
//  movies_embeddedTests
//
//  Created by Jerry Hale on 8/25/17.
//  Copyright © 2017 jhale. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "AccessibilityString.h"

@import EarlGrey;

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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)test_tapMarqueeView
{
	//	just tap on the Marquee
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(AXID_marqueeView)]
      performAction:grey_tap()];
}

//- (void)test_ScrollMarqueeToTop {
//	
//  [[EarlGrey selectElementWithMatcher:grey_accessibilityLabel(AXLABEL_marqueeTableView)]
//      performAction:grey_swipeSlowInDirection(kGREYDirectionUp)];
//}
//
//- (void)test_ScrollMarqueeToBottom {
//  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(AXLABEL_marqueeTableView)]
//      performAction:grey_swipeSlowInDirection(kGREYDirectionDown)];
//}

@end

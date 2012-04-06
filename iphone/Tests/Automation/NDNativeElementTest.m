//
//  NDNativeElementTest.m
//  iPhoneNativeDriver
//
//  Copyright 2011 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "NDNativeElementTest.h"

#import "errorcodes.h"
#import "NDNativeElement.h"
#import "OCMock/OCMock.h"

@implementation NDNativeElementTest

- (void)setUp {
  [super setUp];

  view1_ = [[UIView alloc] init];
  view2_ = [[UIView alloc] init];
  view3_ = [[UIControl alloc] init];
  view4_ = [[UIView alloc] init];

  [view1_ addSubview:view2_];
  [view1_ addSubview:view3_];
  [view3_ addSubview:view4_];
}

- (void)tearDown {
  [view1_ release];
  [view2_ release];
  [view3_ release];
  [view4_ release];
  [super tearDown];
}

- (void)testSubElements {
  NDNativeElement *element1 = [NDNativeElement elementWithView:view1_];
  NSArray *subElements = [element1 subElements];
  STAssertEquals(2U, [subElements count],
                 @"subElements should return direct children");
  STAssertEquals(view2_, [[subElements objectAtIndex:0] view],
                 @"Element should wrap the actual view.");
  STAssertEquals(view3_, [[subElements objectAtIndex:1] view],
                 @"Element should wrap the actual view.");
}

- (void)testAttribute {
  NDNativeElement *element = [NDNativeElement elementWithView:view1_];
  STAssertEqualStrings(@"0", [element attribute:@"tag"],
                       @"Should return property value.");
  [view1_ setTag:42];
  STAssertEqualStrings(@"42", [element attribute:@"tag"],
                       @"Should return current property value.");
}

- (void)testAttributeNotExists {
  NDNativeElement *element = [NDNativeElement elementWithView:view1_];
  STAssertNil([element attribute:@"Dummy"],
              @"Should return nil for invalid attribute name");
}

#pragma mark tests for finsElements

- (void)testfindElementsAll {
  NDNativeElement *element = [NDNativeElement elementWithView:view1_];
  NSArray *result = [element findElementsBy:kByClassName
                                      value:@"UIView"
                                   maxCount:kFindEverything];
  STAssertEquals(4U, [result count], @"Should return all found elements.");
  STAssertEquals(view1_, [[result objectAtIndex:0] view],
                 @"Should refer found view.");
  STAssertEquals(view2_, [[result objectAtIndex:1] view],
                 @"Should refer found view.");
  STAssertEquals(view3_, [[result objectAtIndex:2] view],
                 @"Should refer found view.");
  STAssertEquals(view4_, [[result objectAtIndex:3] view],
                 @"Should refer found view.");
}

- (void)testfindElementsLimitedCount {
  NDNativeElement *element = [NDNativeElement elementWithView:view1_];
  NSArray *result = [element findElementsBy:kByClassName
                                      value:@"UIView"
                                   maxCount:2U];
  STAssertEquals(2U, [result count], @"Should return only 2 elements.");
  STAssertEquals(view1_, [[result objectAtIndex:0] view],
                 @"Should refer found view.");
  STAssertEquals(view2_, [[result objectAtIndex:1] view],
                 @"Should refer found view.");
}

- (void)testfindElementsNotFound {
  NDNativeElement *element = [NDNativeElement elementWithView:view1_];
  NSArray *result = [element findElementsBy:kByClassName
                                      value:@"Dummy"
                                   maxCount:kFindEverything];
  STAssertEquals(0U, [result count], @"Should not return elements");
}

- (void)testfindElementsByNil {
  NDNativeElement *element = [NDNativeElement elementWithView:view1_];
  @try {
    [element findElementsBy:nil value:nil maxCount:kFindEverything];
    STFail(@"Exception should be thrown.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings(@"kWebDriverException", [exception name],
                         @"WebDriverException should be thrown.");
  }
}

- (void)testfindElementsById {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:@"myid"] accessibilityLabel];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kById
                                      value:@"myid"
                                   maxCount:kFindEverything];
  STAssertEquals(1U, [result count], @"Should return found element.");
  STAssertEquals(view5, [[result objectAtIndex:0] view],
                 @"Should refer found view.");

  [view5 verify];
}

- (void)testfindElementsByNilId {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:nil] accessibilityLabel];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kById
                                      value:nil
                                   maxCount:kFindEverything];
  STAssertEquals(0U, [result count], @"Should not return elements");

  [view5 verify];
}

- (void)testfindElementsByText {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:@"abc"] valueForKey:@"text"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByText
                                      value:@"abc"
                                   maxCount:kFindEverything];
  STAssertEquals(1U, [result count], @"Should return found element.");
  STAssertEquals(view5, [[result objectAtIndex:0] view],
                 @"Should refer found view.");

  [view5 verify];
}

- (void)testfindElementsByTitleText {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:nil] valueForKey:@"text"];
  [[[view5 stub] andReturn:@"abc"] valueForKey:@"title"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByText
                                      value:@"abc"
                                   maxCount:kFindEverything];
  STAssertEquals(1U, [result count], @"Should return found element.");
  STAssertEquals(view5, [[result objectAtIndex:0] view],
                 @"Should refer found view.");

  [view5 verify];
}

- (void)testfindElementsByNilText {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:nil] valueForKey:@"text"];
  [[[view5 stub] andReturn:nil] valueForKey:@"title"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByText
                                      value:nil
                                   maxCount:kFindEverything];
  STAssertEquals(0U, [result count], @"Should not return elements");

  [view5 verify];
}

- (void)testfindElementsByPartialTextHitWhole {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:@"abc"] valueForKey:@"text"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByPartialText
                                      value:@"abc"
                                   maxCount:kFindEverything];
  STAssertEquals(1U, [result count], @"Should return found element.");
  STAssertEquals(view5, [[result objectAtIndex:0] view],
                 @"Should refer found view.");

  [view5 verify];
}

- (void)testfindElementsByPartialTextHitPartial {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:@"abc"] valueForKey:@"text"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByPartialText
                                      value:@"b"
                                   maxCount:kFindEverything];
  STAssertEquals(1U, [result count], @"Should return found element.");
  STAssertEquals(view5, [[result objectAtIndex:0] view],
                 @"Should refer found view.");

  [view5 verify];
}

- (void)testfindElementsByPartialTitleText {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:nil] valueForKey:@"text"];
  [[[view5 stub] andReturn:@"abc"] valueForKey:@"title"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByPartialText
                                      value:@"b"
                                   maxCount:kFindEverything];
  STAssertEquals(1U, [result count], @"Should return found element.");
  STAssertEquals(view5, [[result objectAtIndex:0] view],
                 @"Should refer found view.");

  [view5 verify];
}

- (void)testfindElementsByNilPartialText {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:nil] valueForKey:@"text"];
  [[[view5 stub] andReturn:nil] valueForKey:@"title"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByPartialText
                                      value:nil
                                   maxCount:kFindEverything];
  STAssertEquals(0U, [result count], @"Should not return elements");

  [view5 verify];
}

- (void)testfindElementsByClassName {
  NDNativeElement *element = [NDNativeElement elementWithView:view1_];
  NSArray *result = [element findElementsBy:kByClassName
                                      value:@"UIControl"
                                   maxCount:kFindEverything];
  STAssertEquals(1U, [result count], @"Should return UIControl only.");
  STAssertEquals(view3_, [[result objectAtIndex:0] view],
                 @"Should refer found view.");
}

- (void)testfindElementsByNilClassName {
  NDNativeElement *element = [NDNativeElement elementWithView:view1_];
  NSArray *result = [element findElementsBy:kByClassName
                                      value:nil
                                   maxCount:kFindEverything];
  STAssertEquals(0U, [result count], @"Should not return elements");
}

- (void)testfindElementsByPlaceholder {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:@"abc"] valueForKey:@"placeholder"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByPlaceholder
                                      value:@"abc"
                                   maxCount:kFindEverything];
  STAssertEquals(1U, [result count], @"Should return found element.");
  STAssertEquals(view5, [[result objectAtIndex:0] view],
                 @"Should refer found view.");

  [view5 verify];
}

- (void)testfindElementsByNilPlaceholder {
  id view5 = [OCMockObject mockForClass:[UIView class]];
  [[[view5 stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[OCMArg any]];
  [[[view5 stub] andReturn:nil] valueForKey:@"placeholder"];
  [[[view5 stub] andReturn:nil] subviews];
  NDNativeElement *element = [NDNativeElement elementWithView:view5];

  NSArray *result = [element findElementsBy:kByPlaceholder
                                      value:nil
                                   maxCount:kFindEverything];
  STAssertEquals(0U, [result count], @"Should not return elements");

  [view5 verify];
}

#pragma mark tests for other methods

- (void)testIsDisplayed {
  NDNativeElement *element = [NDNativeElement elementWithView:view4_];
  STAssertTrue([element isDisplayed], @"Should return YES in default state.");
}

- (void)testIsDisplayedForHiddenElement {
  NDNativeElement *element = [NDNativeElement elementWithView:view4_];
  [view4_ setHidden:YES];
  STAssertFalse([element isDisplayed],
                @"Should return NO if the element is hidden.");
}

- (void)testIsDisplayedForHiddenAncestor {
  NDNativeElement *element = [NDNativeElement elementWithView:view4_];
  [view1_ setHidden:YES];
  STAssertFalse([element isDisplayed],
                @"Should return NO if any ancestor is hidden.");
}

- (void)testIsEnabled {
  NDNativeElement *element3 = [NDNativeElement elementWithView:view3_];
  STAssertTrue([element3 isEnabled], @"Should return YES in default state.");
  NDNativeElement *element4 = [NDNativeElement elementWithView:view4_];
  STAssertTrue([element4 isEnabled],
               @"Should return YES if the view is not an UIControl.");
}

- (void)testIsEnabledForDisabledElement {
  NDNativeElement *element = [NDNativeElement elementWithView:view3_];
  [view3_ setEnabled:NO];
  STAssertFalse([element isEnabled],
                @"Should return NO if the element is disabled.");
}

- (void)testTagName {
  NDNativeElement *element3 = [NDNativeElement elementWithView:view3_];
  STAssertEqualStrings(@"UIControl", [element3 tagName],
                       @"Should return class name.");
  NDNativeElement *element4 = [NDNativeElement elementWithView:view4_];
  STAssertEqualStrings(@"UIView", [element4 tagName],
                       @"Should return class name.");
}

@end

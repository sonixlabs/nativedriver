//
//  NDWebElementTest.mm
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

#import "NDWebElementTest.h"

#import "atoms.h"
#import "NDWebElement.h"

@interface NDWebElement (PrivateMethods)

- (id)initWithWebView:(UIWebView *)webView
          webDriverId:(NSString *)webDriverId;

@end

// A stub for |NDWebElement| which doesn't send messages to
// |NDJavaScriptRunner|.
@interface NDWebElementStub : NDWebElement {
 @private
  NSString *atom_;
  NSArray *args_;
  id result_;
}

@property(nonatomic, copy) NSString *atom;
@property(nonatomic, retain) NSArray *args;
@property(nonatomic, retain) id result;

- (id)executeAtom:(const char* const)atom
         withArgs:(NSArray *)args;

@end

@implementation NDWebElementStub

@synthesize atom = atom_;
@synthesize args = args_;
@synthesize result = result_;

- (void)dealloc {
  [args_ release];
  [result_ release];
  [super dealloc];
}

- (id)executeAtom:(const char* const)atom
         withArgs:(NSArray *)args {
  self.atom = [NSString stringWithUTF8String:atom];
  self.args = args;
  return self.result;
}

@end

@implementation NDWebElementTest

- (void)testFindElements {
  // Prepare stub.
  NDWebElementStub *element =
      [[[NDWebElementStub alloc] initWithWebView:nil
                                     webDriverId:@"123"] autorelease];
  NSDictionary *id1 = [NSDictionary dictionaryWithObject:@"456"
                                                  forKey:@"ELEMENT"];
  NSDictionary *id2 = [NSDictionary dictionaryWithObject:@"789"
                                                  forKey:@"ELEMENT"];
  element.result = [NSArray arrayWithObjects:id1, id2, nil];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"value1"
                                  maxCount:kFindEverything];

  // Asserts.
  NSString *findElements =
      [NSString stringWithUTF8String:webdriver::atoms::FIND_ELEMENTS];
  STAssertEqualStrings(findElements, [element atom],
                       @"Should call FIND_ELEMENTS.");
  NSDictionary *locator = [NSDictionary dictionaryWithObject:@"value1"
                                                      forKey:@"id"];
  NSDictionary *idDict = [NSDictionary dictionaryWithObject:@"123"
                                                     forKey:@"ELEMENT"];
  NSArray *expectedArgs = [NSArray arrayWithObjects:locator, idDict, nil];
  STAssertTrue([[element args] isEqualToArray:expectedArgs],
               @"Args should be correct.");
  STAssertEquals(2U, [array count], @"Should return found elements.");
  STAssertEqualStrings(@"456", [[array objectAtIndex:0] webDriverId],
                       @"Should return first found elements.");
  STAssertEqualStrings(@"789", [[array objectAtIndex:1] webDriverId],
                       @"Should return second found elements.");
}

- (void)testFindElementsNotFound {
  // Prepare stub.
  NDWebElementStub *element =
      [[[NDWebElementStub alloc] initWithWebView:nil
                                     webDriverId:@"123"] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"value1"
                                  maxCount:kFindEverything];

  // Asserts.
  NSString *findElements =
      [NSString stringWithUTF8String:webdriver::atoms::FIND_ELEMENTS];
  STAssertEqualStrings(findElements, [element atom],
                       @"Should call FIND_ELEMENTS.");
  NSDictionary *locator = [NSDictionary dictionaryWithObject:@"value1"
                                                      forKey:@"id"];
  NSDictionary *idDict = [NSDictionary dictionaryWithObject:@"123"
                                                     forKey:@"ELEMENT"];
  NSArray *expectedArgs = [NSArray arrayWithObjects:locator, idDict, nil];
  STAssertTrue([[element args] isEqualToArray:expectedArgs],
               @"Args should be correct.");
  STAssertEquals(0U, [array count], @"Should not return elements.");
}

- (void)testFindOnlyOneElement {
  // Prepare stub.
  NDWebElementStub *element =
      [[[NDWebElementStub alloc] initWithWebView:nil
                                     webDriverId:@"123"] autorelease];
  element.result = [NSDictionary dictionaryWithObject:@"456"
                                               forKey:@"ELEMENT"];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"value1"
                                  maxCount:1U];

  // Asserts.
  NSString *findElements =
      [NSString stringWithUTF8String:webdriver::atoms::FIND_ELEMENT];
  STAssertEqualStrings(findElements, [element atom],
                       @"Should call FIND_ELEMENT.");
  NSDictionary *locator = [NSDictionary dictionaryWithObject:@"value1"
                                                      forKey:@"id"];
  NSDictionary *idDict = [NSDictionary dictionaryWithObject:@"123"
                                                     forKey:@"ELEMENT"];
  NSArray *expectedArgs = [NSArray arrayWithObjects:locator, idDict, nil];
  STAssertTrue([[element args] isEqualToArray:expectedArgs],
               @"Args should be correct.");
  STAssertEquals(1U, [array count], @"Should return found elements.");
  STAssertEqualStrings(@"456", [[array objectAtIndex:0] webDriverId],
                       @"Should return first found elements.");
}

- (void)testFindOnlyOneElementNotFound {
  // Prepare stub.
  NDWebElementStub *element =
      [[[NDWebElementStub alloc] initWithWebView:nil
                                     webDriverId:@"123"] autorelease];
  element.result = [NSNull null];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"value1"
                                  maxCount:1U];

  // Asserts.
  NSString *findElements =
      [NSString stringWithUTF8String:webdriver::atoms::FIND_ELEMENT];
  STAssertEqualStrings(findElements, [element atom],
                       @"Should call FIND_ELEMENT.");
  NSDictionary *locator = [NSDictionary dictionaryWithObject:@"value1"
                                                      forKey:@"id"];
  NSDictionary *idDict = [NSDictionary dictionaryWithObject:@"123"
                                                     forKey:@"ELEMENT"];
  NSArray *expectedArgs = [NSArray arrayWithObjects:locator, idDict, nil];
  STAssertTrue([[element args] isEqualToArray:expectedArgs],
               @"Args should be correct.");
  STAssertEquals(0U, [array count], @"Should not return elements.");
}

- (void)testFindElementsWithMaxCount {
  // Prepare stub.
  NDWebElementStub *element =
      [[[NDWebElementStub alloc] initWithWebView:nil
                                     webDriverId:@"123"] autorelease];
  NSDictionary *id1 = [NSDictionary dictionaryWithObject:@"456"
                                                  forKey:@"ELEMENT"];
  NSDictionary *id2 = [NSDictionary dictionaryWithObject:@"567"
                                                  forKey:@"ELEMENT"];
  NSDictionary *id3 = [NSDictionary dictionaryWithObject:@"678"
                                                  forKey:@"ELEMENT"];
  element.result = [NSArray arrayWithObjects:id1, id2, id3, nil];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"value1"
                                  maxCount:2U];

  // Asserts.
  NSString *findElements =
      [NSString stringWithUTF8String:webdriver::atoms::FIND_ELEMENTS];
  STAssertEqualStrings(findElements, [element atom],
                       @"Should call FIND_ELEMENTS.");
  NSDictionary *locator = [NSDictionary dictionaryWithObject:@"value1"
                                                      forKey:@"id"];
  NSDictionary *idDict = [NSDictionary dictionaryWithObject:@"123"
                                                     forKey:@"ELEMENT"];
  NSArray *expectedArgs = [NSArray arrayWithObjects:locator, idDict, nil];
  STAssertTrue([[element args] isEqualToArray:expectedArgs],
               @"Args should be correct.");
  STAssertEquals(2U, [array count], @"Should return only 2 elements.");
  STAssertEqualStrings(@"456", [[array objectAtIndex:0] webDriverId],
                       @"Should return first found elements.");
  STAssertEqualStrings(@"567", [[array objectAtIndex:1] webDriverId],
                       @"Should return second found elements.");
}

- (void)testFindElementsByPartialLinkText {
  // Prepare stub.
  NDWebElementStub *element =
      [[[NDWebElementStub alloc] initWithWebView:nil
                                     webDriverId:@"123"] autorelease];

  // Call findElements.
  [element findElementsBy:kByPartialLinkText
                    value:@"value1"
                 maxCount:kFindEverything];

  // Asserts.
  NSDictionary *locator =
      [NSDictionary dictionaryWithObject:@"value1" forKey:@"partialLinkText"];
  NSDictionary *idDict = [NSDictionary dictionaryWithObject:@"123"
                                                     forKey:@"ELEMENT"];
  NSArray *expectedArgs = [NSArray arrayWithObjects:locator, idDict, nil];
  STAssertTrue([[element args] isEqualToArray:expectedArgs],
               @"Strategy should be converted.");
}

- (void)testFindElementsByUnknownStrategy {
  // Prepare stub.
  NDWebElementStub *element =
      [[[NDWebElementStub alloc] initWithWebView:nil
                                     webDriverId:@"123"] autorelease];

  // Call findElements.
  @try {
    [element findElementsBy:@"dummy" value:@"value1" maxCount:kFindEverything];
    STFail(@"Exception should be thrown.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings(@"kWebDriverException", [exception name],
                         @"WebDriverException should be thrown.");
  }
}

- (void)testFindElementsFromRoot {
  // Prepare stub.
  NDWebElementStub *element =
      [[[NDWebElementStub alloc] initWithWebView:nil
                                     webDriverId:nil] autorelease];

  // Call findElements.
  [element findElementsBy:kById value:@"value1" maxCount:kFindEverything];

  // Asserts.
  NSDictionary *locator =
      [NSDictionary dictionaryWithObject:@"value1" forKey:@"id"];
  NSArray *expectedArgs = [NSArray arrayWithObject:locator];
  STAssertTrue([[element args] isEqualToArray:expectedArgs],
               @"Args should not have id dictionary.");
}

@end

//
//  NDNativeWebViewElementTest.mm
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

#import "NDNativeWebViewElementTest.h"

#import "atoms.h"
#import "NDNativeWebViewElement.h"
#import "NDWebElement.h"
#import "OCMock/OCMock.h"

@implementation NDNativeWebViewElementTest

- (void)testFindElements {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  [[[webView stub] andReturn:@"id1"] accessibilityLabel];
  [[[webView stub] andReturn:
      @"{\"status\":0, \"value\":[{\"ELEMENT\":\"1\"}, {\"ELEMENT\":\"2\"}]}"]
      stringByEvaluatingJavaScriptFromString:[OCMArg any]];
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"id1"
                                  maxCount:kFindEverything];

  // Asserts.
  STAssertEquals(3U, [array count], @"Should return found elements.");
  STAssertEquals([array objectAtIndex:0], element,
                 @"Should find itself first.");
  STAssertEqualStrings(@"1", [[array objectAtIndex:1] webDriverId],
                       @"Should return found element.");
  STAssertEqualStrings(@"2", [[array objectAtIndex:2] webDriverId],
                       @"Should return found element.");
  [webView verify];
}

- (void)testFindElementsNotFound {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  [[[webView stub] andReturn:nil] accessibilityLabel];
  [[[webView stub] andReturn:@"{\"status\":0, \"value\":[]}"]
      stringByEvaluatingJavaScriptFromString:[OCMArg any]];
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"id1"
                                  maxCount:kFindEverything];

  // Asserts.
  STAssertEquals(0U, [array count], @"Should not return elements.");
  [webView verify];
}

- (void)testFindOnlyOneElementFromNative {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  [[[webView stub] andReturn:@"id1"] accessibilityLabel];
  // Should not call stringByEvaluatingJavaScriptFromString.
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"id1"
                                  maxCount:1U];

  // Asserts.
  STAssertEquals(1U, [array count], @"Should return first found element.");
  STAssertEquals([array objectAtIndex:0], element,
                 @"Should find itself first.");
  [webView verify];
}

- (void)testFindOnlyOneElementFromWeb {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  [[[webView stub] andReturn:nil] accessibilityLabel];
  [[[webView stub] andReturn:@"{\"status\":0, \"value\":{\"ELEMENT\":\"1\"}}"]
      stringByEvaluatingJavaScriptFromString:[OCMArg any]];
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"id1"
                                  maxCount:1U];

  // Asserts.
  STAssertEquals(1U, [array count], @"Should return first found element.");
  STAssertEqualStrings(@"1", [[array objectAtIndex:0] webDriverId],
                       @"Should return found element.");
  [webView verify];
}

- (void)testFindOnlyOneElementNotFound {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  [[[webView stub] andReturn:nil] accessibilityLabel];
  [[[webView stub] andReturn:@"{\"status\":0, \"value\":null}"]
   stringByEvaluatingJavaScriptFromString:[OCMArg any]];
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"id1"
                                  maxCount:1U];

  // Asserts.
  STAssertEquals(0U, [array count], @"Should not return elements.");
  [webView verify];
}

- (void)testFindElementsWithMaxCount2 {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  [[[webView stub] andReturn:@"id1"] accessibilityLabel];
  // FIND_ELEMENT should be called.
  NSString *executeScript =
      [NSString stringWithFormat:@"(%@)(%@,[{\"id\":\"id1\"}],true)",
          [NSString stringWithUTF8String:webdriver::atoms::EXECUTE_SCRIPT],
          [NSString stringWithUTF8String:webdriver::atoms::FIND_ELEMENT]];
  [[[webView stub] andReturn:@"{\"status\":0, \"value\":{\"ELEMENT\":\"1\"}}"]
      stringByEvaluatingJavaScriptFromString:executeScript];
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"id1"
                                  maxCount:2U];

  // Asserts.
  STAssertEquals(2U, [array count], @"Should return found elements.");
  STAssertEquals([array objectAtIndex:0], element,
                 @"Should find itself first.");
  STAssertEqualStrings(@"1", [[array objectAtIndex:1] webDriverId],
                       @"Should return found element.");
  [webView verify];
}

- (void)testFindElementsWithMaxCount3 {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  [[[webView stub] andReturn:@"id1"] accessibilityLabel];
  // FIND_ELEMENTS should be called.
  NSString *executeScript =
      [NSString stringWithFormat:@"(%@)(%@,[{\"id\":\"id1\"}],true)",
          [NSString stringWithUTF8String:webdriver::atoms::EXECUTE_SCRIPT],
          [NSString stringWithUTF8String:webdriver::atoms::FIND_ELEMENTS]];
  [[[webView stub] andReturn:@"{\"status\":0, \"value\":[{\"ELEMENT\":\"1\"},"
      @"{\"ELEMENT\":\"2\"}, {\"ELEMENT\":\"3\"}, {\"ELEMENT\":\"4\"}]}"]
      stringByEvaluatingJavaScriptFromString:executeScript];
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kById
                                     value:@"id1"
                                  maxCount:3U];

  // Asserts.
  STAssertEquals(3U, [array count], @"Should return only 3 elements.");
  STAssertEquals([array objectAtIndex:0], element,
                 @"Should find itself first.");
  STAssertEqualStrings(@"1", [[array objectAtIndex:1] webDriverId],
                       @"Should return found element.");
  STAssertEqualStrings(@"2", [[array objectAtIndex:2] webDriverId],
                       @"Should return found element.");
  [webView verify];
}

- (void)testByPlaceholderTest {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  [[[webView stub] andReturn:@"placeholder1"] valueForKey:@"placeholder"];
  // Should not call stringByEvaluatingJavaScriptFromString.
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kByPlaceholder
                                     value:@"placeholder1"
                                  maxCount:kFindEverything];

  // Asserts.
  STAssertEquals(1U, [array count], @"Should return found element.");
  STAssertEquals([array objectAtIndex:0], element,
                 @"Should return found element.");
  [webView verify];
}

- (void)testByCssSelectorTest {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  // Should not call accessibilityLabel or valueForKey.
  [[[webView stub] andReturn:
      @"{\"status\":0, \"value\":[{\"ELEMENT\":\"1\"}, {\"ELEMENT\":\"2\"}]}"]
      stringByEvaluatingJavaScriptFromString:[OCMArg any]];
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  NSArray *array = [element findElementsBy:kByCssSelector
                                     value:@"cssSelector"
                                  maxCount:kFindEverything];

  // Asserts.
  STAssertEquals(2U, [array count], @"Should return found elements.");
  STAssertEqualStrings(@"1", [[array objectAtIndex:0] webDriverId],
                       @"Should return found element.");
  STAssertEqualStrings(@"2", [[array objectAtIndex:1] webDriverId],
                       @"Should return found element.");
  [webView verify];
}

- (void)testByUnknownStrategy {
  // Prepare stub.
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  NDNativeWebViewElement *element =
      [[[NDNativeWebViewElement alloc] initWithView:webView] autorelease];

  // Call findElements.
  @try {
    [element findElementsBy:@"dummy"
                      value:@"dummy"
                   maxCount:kFindEverything];
    STFail(@"Exception should be thrown.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings(@"kWebDriverException", [exception name],
                         @"WebDriverException should be thrown.");
  }
  [webView verify];
}

@end

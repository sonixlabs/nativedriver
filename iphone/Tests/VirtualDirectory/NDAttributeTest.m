//
//  NDAttributeTest.m
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

#import "NDAttributeTest.h"

#import "NDElementDirectory.h"
#import "NDNativeElement.h"

@implementation NDAttributeTest

- (void)testGetAttribute {
  UIView *view = [[[UIView alloc] init] autorelease];
  [view setTag:123];

  NDElement *element = [NDNativeElement elementWithView:view];
  NDElementDirectory *directory =
      [NDElementDirectory directoryWithElement:element elementStore:nil];

  NSString *result = [[directory httpResponseForQuery:@"attribute/tag"
                                               method:@"GET"
                                             withData:nil] description];
  STAssertEqualStrings(@"{ status: 0, value:123 }", result,
                       @"Should return view's property.");

  // Reusing exising /tag directory should return latest attribute value.
  [view setTag:456];
  result = [[directory httpResponseForQuery:@"attribute/tag"
                                     method:@"GET"
                                   withData:nil] description];
  STAssertEqualStrings(@"{ status: 0, value:456 }", result,
                       @"Should return view's property.");
}

- (void)testAttributeDirectoryWithoutSlash {
  NDElementDirectory *directory =
      [NDElementDirectory directoryWithElement:nil elementStore:nil];
  id<HTTPResponse> result = [directory httpResponseForQuery:@"attribute"
                                                     method:@"GET"
                                                   withData:nil];
  STAssertNil(result, @"Should not respond to /attribute URL.");
}

- (void)testAttributeDirectoryWithSlash {
  NDElementDirectory *directory =
      [NDElementDirectory directoryWithElement:nil elementStore:nil];
  id<HTTPResponse> result = [directory httpResponseForQuery:@"attribute/"
                                                     method:@"GET"
                                                   withData:nil];
  STAssertNil(result, @"Should not respond to /attribute/ URL.");
}

- (void)testAttributeNotExist {
  NDElementDirectory *directory =
      [NDElementDirectory directoryWithElement:nil elementStore:nil];
  NSString *result = [[directory httpResponseForQuery:@"attribute/x"
                                               method:@"GET"
                                             withData:nil] description];
  // WebDriver's wiki page says "..., or null if it is not set on the element."
  STAssertEqualStrings(@"{ status: 0, value:(null) }", result,
                       @"Should return null value.");
}

@end

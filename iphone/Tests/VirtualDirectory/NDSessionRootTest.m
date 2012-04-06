//
//  NDSessionRootTest.m
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

#import "NDSessionRootTest.h"
#import "NDSessionRoot.h"

// A dummy interface to access the private method.
@interface NSObject (RedirectURL)

- (NSString *)redirectURL;

@end

@implementation NDSessionRootTest

- (void)testCreateSessions {
  NDSessionRoot *root = [[[NDSessionRoot alloc] init] autorelease];

  NSObject<HTTPResponse> *response =
      [root httpResponseForQuery:@"/" method:@"POST" withData:nil];
  STAssertEqualStrings(@"session/0/", [response redirectURL],
      @"Should redirect to session URL.");

  response = [root httpResponseForQuery:@"/" method:@"POST" withData:nil];
  STAssertEqualStrings(@"session/1/", [response redirectURL],
      @"Should return new id.");

  [root httpResponseForQuery:@"0" method:@"DELETE" withData:nil];
  [root httpResponseForQuery:@"1" method:@"DELETE" withData:nil];
}

@end

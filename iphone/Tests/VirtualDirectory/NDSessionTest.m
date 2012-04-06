//
//  NDSessionTest.m
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

#import "NDSessionTest.h"

#import "NDSession.h"
#import "NDSessionRoot.h"
#import "OCMock/OCMock.h"

// Private initializer of NDSession.
@interface NDSession ()

- (id)initWithSessionRoot:(NDSessionRoot *)root
                sessionId:(int)sessionId;

@end

// Stub of NDSession. Overrides |keyWindow|.
@interface NDSessionStub : NDSession {
 @private
  UIWindow *keyWindow_;
}

@property(nonatomic, retain) UIWindow *keyWindow;

@end

@implementation NDSessionStub

@synthesize keyWindow = keyWindow_;

- (void)dealloc {
  [keyWindow_ release];
  [super dealloc];
}

@end

@implementation NDSessionTest

- (void)testCapabilities {
  NDSessionRoot *root = [[[NDSessionRoot alloc] init] autorelease];
  [root httpResponseForQuery:@"/" method:@"POST" withData:nil];
  NSString *capabilities = [NSString stringWithFormat:@"%@",
      [root httpResponseForQuery:@"0" method:@"GET" withData:nil]];

  NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
  NSString *expected = [NSString stringWithFormat:
      @"{ status: 0, value:{\n"
      @"    browserName = \"ios native\";\n"
      @"    platform = IOS;\n"
      @"    version = \"%@\";\n"
      @"} }", deviceVersion];
  STAssertEqualStrings(expected, capabilities,
      @"Should return correct capabilities.");

  [root httpResponseForQuery:@"0" method:@"DELETE" withData:nil];
}

- (void)testTitle {
  id rootViewController =
      [OCMockObject mockForClass:[UINavigationController class]];
  [[[rootViewController stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[UINavigationController class]];
  [[[rootViewController stub] andReturn:@"title!"] title];
  id keyWindow = [OCMockObject mockForClass:[UIWindow class]];
  [[[keyWindow stub] andReturn:rootViewController] rootViewController];
  NDSessionStub *session =
      [[[NDSessionStub alloc] initWithSessionRoot:nil sessionId:0] autorelease];
  session.keyWindow = keyWindow;

  NSString *title = [[session httpResponseForQuery:@"/title"
                                            method:@"GET"
                                          withData:nil] description];
  STAssertEqualStrings(@"{ status: 0, value:title! }", title,
                       @"Should return correct title.");
}

- (void)testTitleUINavigationController {
  id navigationItem = [OCMockObject mockForClass:[UINavigationItem class]];
  [[[navigationItem stub] andReturn:@"title!"] title];
  id topViewController = [OCMockObject mockForClass:[UIViewController class]];
  [[[topViewController stub] andReturn:navigationItem] navigationItem];
  id rootViewController =
      [OCMockObject mockForClass:[UINavigationController class]];
  [[[rootViewController stub] andReturnValue:[NSNumber numberWithBool:YES]]
      isKindOfClass:[UINavigationController class]];
  [[[rootViewController stub] andReturn:topViewController] topViewController];
  id keyWindow = [OCMockObject mockForClass:[UIWindow class]];
  [[[keyWindow stub] andReturn:rootViewController] rootViewController];
  NDSessionStub *session =
      [[[NDSessionStub alloc] initWithSessionRoot:nil sessionId:0] autorelease];
  session.keyWindow = keyWindow;

  NSString *title = [[session httpResponseForQuery:@"/title"
                                            method:@"GET"
                                          withData:nil] description];
  STAssertEqualStrings(@"{ status: 0, value:title! }", title,
                       @"Should return correct title.");
}

@end

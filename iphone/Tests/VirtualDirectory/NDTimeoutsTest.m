//
//  NDTimeoutsTest.m
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

#import "NDTimeoutsTest.h"

#import "NDSession.h"
#import "NDTimeouts.h"

@implementation NDTimeoutsTest

- (void)assertString:(NSString *)string
            contains:(NSString *)substring
        errorMessage:(NSString *)errorMessage {
  STAssertTrue([string rangeOfString:substring].location != NSNotFound,
               errorMessage);
}

- (void)testSetImplicitWait {
  NDSession *session = [NDSession sessionWithSessionRoot:nil sessionId:0];
  STAssertEquals(0.0, [session implicitWait],
                 @"Default timeout should be 0 second.");
  NSData *data = [NSData dataWithBytes:"{\"ms\":3000}" length:11];
  [session httpResponseForQuery:@"timeouts/implicit_wait"
                         method:@"POST"
                       withData:data];
  STAssertEquals(3.0, [session implicitWait], @"Should be updated.");
}

- (void)testSetImplicitWaitZero {
  NDSession *session = [NDSession sessionWithSessionRoot:nil sessionId:0];
  STAssertEquals(0.0, [session implicitWait],
                 @"Default timeout should be 0 second.");
  NSData *data = [NSData dataWithBytes:"{\"ms\":0}" length:8];
  [session httpResponseForQuery:@"timeouts/implicit_wait"
                         method:@"POST"
                       withData:data];
  STAssertEquals(0.0, [session implicitWait], @"Should be updated.");
}

- (void)testSetImplicitWaitNegative {
  NDSession *session = [NDSession sessionWithSessionRoot:nil sessionId:0];
  [session setImplicitWait:1.0];
  NSData *data = [NSData dataWithBytes:"{\"ms\":-3000}" length:12];
  NSString *response = [[session httpResponseForQuery:@"timeouts/implicit_wait"
                                               method:@"POST"
                                             withData:data] description];
  STAssertEquals(1.0, [session implicitWait], @"Should not be updated.");
  [self assertString:response
            contains:@"ImplicitWait should be positive or 0."
        errorMessage:@"Should contains error message."];
}

- (void)testSetImplicitWaitInvalidValue {
  NDSession *session = [NDSession sessionWithSessionRoot:nil sessionId:0];
  [session setImplicitWait:1.0];
  NSData *data = [NSData dataWithBytes:"{\"ms\":\"ABC\"}" length:12];
  NSString *response = [[session httpResponseForQuery:@"timeouts/implicit_wait"
                                               method:@"POST"
                                             withData:data] description];
  STAssertEquals(1.0, [session implicitWait], @"Should not be updated.");
  [self assertString:response
            contains:@"ImplicitWait should be a number."
        errorMessage:@"Should contains error message."];
}

- (void)testSetImplicitWaitWithoutData {
  NDSession *session = [NDSession sessionWithSessionRoot:nil sessionId:0];
  [session setImplicitWait:1.0];
  NSData *data = [NSData dataWithBytes:"{}" length:2];
  NSString *response = [[session httpResponseForQuery:@"timeouts/implicit_wait"
                                               method:@"POST"
                                             withData:data] description];
  NSLog(@"%@", response);
  STAssertEquals(1.0, [session implicitWait], @"Should not be updated.");
  [self assertString:response
            contains:@"ImplicitWait should be a number."
        errorMessage:@"Should contains error message."];
}

@end

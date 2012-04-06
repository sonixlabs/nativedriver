//
//  NDElementDirectoryTest.m
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

#import "NDElementDirectoryTest.h"

@interface NDElementDirectoryTest ()

- (void)postRequest:(NSString *)query;
- (void)getRequest:(NSString *)query;
- (void)checkIsAliveCalled:(BOOL)isAliveCalled
        isSelectableCalled:(BOOL)isSelectableCalled
           isVisibleCalled:(BOOL)isVisibleCalled
           isEnabledCalled:(BOOL)isEnabledCalled;

@end

// Allow access to private initializer
@interface NDElementDirectory ()

- (id)initWithElement:(NDElement *)element
         elementStore:(NDElementStore *)elementStore;

@end

@implementation NDElementDirectoryStub

@synthesize verifyElementStillAliveCalled = verifyElementStillAliveCalled_;
@synthesize verifyElementSelectableCalled = verifyElementSelectableCalled_;
@synthesize verifyElementVisibleCalled = verifyElementVisibleCalled_;
@synthesize verifyElementEnabledCalled = verifyElementEnabledCalled_;

- (void)verifyElementStillAlive {
  verifyElementStillAliveCalled_ = YES;
}

- (void)verifyElementSelectable {
  verifyElementSelectableCalled_ = YES;
}

- (void)verifyElementVisible {
  verifyElementVisibleCalled_ = YES;
}

- (void)verifyElementEnabled {
  verifyElementEnabledCalled_ = YES;
}

@end

@implementation NDElementDirectoryTest

- (void)setUp {
  [super setUp];
  directory_ = [[[NDElementDirectoryStub alloc] initWithElement:nil
                                                   elementStore:nil] retain];
}

- (void)tearDown {
  [directory_ release];
  [super tearDown];
}

- (void)postRequest:(NSString *)query {
  [directory_ httpResponseForQuery:query
                            method:@"POST"
                          withData:[NSData dataWithBytes:"{}" length:2]];
}

- (void)getRequest:(NSString *)query {
  [directory_ httpResponseForQuery:query
                            method:@"GET"
                          withData:nil];
}

- (void)checkIsAliveCalled:(BOOL)isAliveCalled
        isSelectableCalled:(BOOL)isSelectableCalled
           isVisibleCalled:(BOOL)isVisibleCalled
           isEnabledCalled:(BOOL)isEnabledCalled {
  STAssertEquals(isAliveCalled, [directory_ verifyElementStillAliveCalled],
                 @"verifyElementStillAlive %@ be called.",
                 (isAliveCalled ? @"should" : @"should not"));
  STAssertEquals(isSelectableCalled, [directory_ verifyElementSelectableCalled],
                 @"verifyElementSelectableCalled %@ be called.",
                 (isSelectableCalled ? @"should" : @"should not"));
  STAssertEquals(isVisibleCalled, [directory_ verifyElementVisibleCalled],
                 @"verifyElementVisibleCalled %@ be called.",
                 (isVisibleCalled ? @"should" : @"should not"));
  STAssertEquals(isEnabledCalled, [directory_ verifyElementEnabledCalled],
                 @"verifyElementEnabledCalled %@ be called.",
                 (isEnabledCalled ? @"should" : @"should not"));
}

- (void)testClear {
  [self postRequest:@"clear"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:YES
           isEnabledCalled:YES];
}

- (void)testClick {
  [self postRequest:@"click"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:YES
           isEnabledCalled:NO];
}

- (void)testIsDisplayed {
  [self getRequest:@"displayed"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:NO
           isEnabledCalled:NO];
}

- (void)testIsEnabled {
  [self getRequest:@"enabled"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:NO
           isEnabledCalled:NO];
}

- (void)testIsSelected {
  [self getRequest:@"selected"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:NO
           isEnabledCalled:NO];
}

- (void)testSendKeys {
  [self postRequest:@"value"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:YES
           isEnabledCalled:NO];
}

- (void)testSubmit {
  [self postRequest:@"submit"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:YES
           isEnabledCalled:NO];
}

- (void)testTagName {
  [self getRequest:@"name"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:NO
           isEnabledCalled:NO];
}

- (void)testText {
  [self getRequest:@"text"];
  [self checkIsAliveCalled:YES
        isSelectableCalled:NO
           isVisibleCalled:NO
           isEnabledCalled:NO];
}

@end

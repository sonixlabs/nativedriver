//
//  NDTimeouts.m
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


#import "NDTimeouts.h"

#import "errorcodes.h"
#import "NDSession.h"
#import "NSException+WebDriver.h"
#import "WebDriverResource.h"

@interface NDTimeouts ()

- (id)initWithSession:(NDSession *)session;

- (void)setImplicitWait:(NSDictionary *)params;

@end

@implementation NDTimeouts

- (id)initWithSession:(NDSession *)session {
  if ((self = [super init])) {
    session_ = session;

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:nil
                               POSTAction:@selector(setImplicitWait:)]
             withName:@"implicit_wait"];
  }
  return self;
}

+ (NDTimeouts *)timeoutsWithSession:(NDSession *)session {
  return [[[NDTimeouts alloc] initWithSession:session] autorelease];
}

// Sets implicit wait value. The value should be a positive number in
// milliseconds
- (void)setImplicitWait:(NSDictionary *)params {
  id msValue = [params objectForKey:@"ms"];
  if (![msValue isKindOfClass:[NSNumber class]]) {
    @throw [NSException
        webDriverExceptionWithMessage:@"ImplicitWait should be a number."
                        andStatusCode:EUNHANDLEDERROR];
  }
  double wait = [msValue doubleValue];
  if (wait < 0.0) {
    @throw [NSException
        webDriverExceptionWithMessage:@"ImplicitWait should be positive or 0."
                        andStatusCode:EUNHANDLEDERROR];
  }
  // The unit of NSTimeInterval is seconds.
  [session_ setImplicitWait:(wait / 1000.0)];
}

@end

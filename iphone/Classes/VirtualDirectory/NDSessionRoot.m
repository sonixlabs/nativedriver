//
//  NDSessionRoot.m
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

#import "NDSessionRoot.h"

#import "HTTPRedirectResponse.h"
#import "JSONRESTResource.h"
#import "NDSession.h"

@implementation NDSessionRoot

- (id)init {
  if ((self = [super init])) {
    // Sessions are created by POSTing to /hub/session with
    // a set of |DesiredCapabilities|.
    [self setIndex:[JSONRESTResource
                    JSONResourceWithTarget:self
                    action:@selector(createSessionWithData:method:)]];
  }
  return self;
}

// Create a session. This method is bound to the index of /hub/session/.
- (id<HTTPResponse>)createSessionWithData:(id)desiredCapabilities
                                   method:(NSString *)method {
  if (![method isEqualToString:@"POST"] && ![method isEqualToString:@"GET"])
    return nil;

  int sessionId = nextId_++;

  NDSession* session = [NDSession sessionWithSessionRoot:self
                                               sessionId:sessionId];

  NSString *sessionIdStr = [NSString stringWithFormat:@"%d", sessionId];
  [self setResource:session withName:sessionIdStr];

  return [HTTPRedirectResponse redirectToURL:
          [NSString stringWithFormat:@"session/%d/", sessionId]];
}

- (void)deleteSessionWithId:(int)sessionId {
  NSString *sessionIdStr = [NSString stringWithFormat:@"%d", sessionId];
  [self setResource:nil withName:sessionIdStr];
}

@end

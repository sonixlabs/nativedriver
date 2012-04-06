//
//  NDSession.m
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

#import "NDSession.h"

#import "NDElementStore.h"
#import "NDSessionRoot.h"
#import "NDTimeouts.h"
#import "WebDriverResource.h"

@interface NDSession ()

- (id)initWithSessionRoot:(NDSessionRoot *)root
                sessionId:(int)sessionId;

- (NSDictionary *)capabilities;
- (NSString *)title;

@end

@implementation NDSession

@synthesize sessionId = sessionId_;
@synthesize elementStore = elementStore_;
@synthesize implicitWait = implicitWait_;

- (NDSession *)initWithSessionRoot:(NDSessionRoot *)root
                         sessionId:(int)sessionId {
  if ((self = [super init])) {
    sessionRoot_ = root;
    sessionId_ = sessionId;

    // Creates NDElementStore. elementStoreWithSession will register itself
    // as the /element and /elements virtual directory.
    elementStore_ = [[NDElementStore elementStoreWithSession:self] retain];

    [self setIndex:[WebDriverResource
                    resourceWithTarget:self
                             GETAction:@selector(capabilities)
                            POSTAction:nil
                             PUTAction:nil
                          DELETEAction:@selector(deleteSession)]];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:@selector(title)
                               POSTAction:nil]
             withName:@"title"];

    [self setResource:[NDTimeouts timeoutsWithSession:self]
             withName:@"timeouts"];
  }
  return self;
}

- (void)dealloc {
  [elementStore_ release];
  [super dealloc];
}

+ (NDSession *)sessionWithSessionRoot:(NDSessionRoot *)root
                            sessionId:(int)sessionId {
  return [[[NDSession alloc] initWithSessionRoot:root
                                       sessionId:sessionId] autorelease];
}

- (void)deleteSession {
  // Tell the session root to remove this resource.
  [sessionRoot_ deleteSessionWithId:sessionId_];
}

// Returns this driver's capabilities. Since capabilities JSON Object represents
// browser spec, it doesn't exactly match to native applications. This method
// returns special browser name and platform name for NativeDriver.
- (NSDictionary *)capabilities {
  NSMutableDictionary *caps = [NSMutableDictionary dictionary];
  [caps setObject:@"ios native" forKey:@"browserName"];
  [caps setObject:[[UIDevice currentDevice] systemVersion] forKey:@"version"];
  [caps setObject:@"IOS" forKey:@"platform"];
  return caps;
}

// Returns current key window.
- (UIWindow *)keyWindow {
  return [[UIApplication sharedApplication] keyWindow];
}

// Returns title on the navigation bar. If the target application is not
// navigation based, returns the controller's title.
- (NSString *)title {
  UIViewController *controller = [[self keyWindow] rootViewController];
  if ([controller isKindOfClass:[UINavigationController class]]) {
    return [[[(UINavigationController *)controller topViewController]
             navigationItem] title];
  }
  return [controller title];
}

// Override to set session id for each |WebDriverResource|.
// |elementWithQuery:| is recursively called, so this will effect all resources
// under /session/:sessionid directory.
- (id<HTTPResource>)elementWithQuery:(NSString *)query {
  id<HTTPResource> resource = [super elementWithQuery:query];
  if ([resource isKindOfClass:[WebDriverResource class]]) {
    NSString *sessionIdString = [NSString stringWithFormat:@"%d", sessionId_];
    [(WebDriverResource *)resource setSession:sessionIdString];
  }
  return resource;
}

@end

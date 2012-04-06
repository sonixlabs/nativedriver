//
//  NDSession.h
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

#import <Foundation/Foundation.h>
#import "HTTPVirtualDirectory.h"

@class NDElementStore;
@class NDSessionRoot;

// This |HTTPVirtualDirectory| matches the /:session directory which WebDriver
// expects.
@interface NDSession : HTTPVirtualDirectory {
 @private
  NDSessionRoot *sessionRoot_;  // the parent session root (weak)
  int sessionId_;
  NDElementStore *elementStore_;
  NSTimeInterval implicitWait_;
}

@property(nonatomic, readonly) int sessionId;
@property(nonatomic, retain) NDElementStore *elementStore;
@property(nonatomic) NSTimeInterval implicitWait;

// Makes a session directory. Note |root| is a weak pointer. The caller needs to
// ensure its lifetime outlives this object.
+ (NDSession *)sessionWithSessionRoot:(NDSessionRoot *)root
                            sessionId:(int)sessionId;

// Deletes this session. Calling this multiple times has no effect. This method
// calls session root's deleteSessionWithId method.
- (void)deleteSession;

@end

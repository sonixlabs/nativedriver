//
//  NDSessionRoot.h
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

// This |HTTPVirtualDirectory| matches the /session directory that serves as the
// root of the WebDriver REST service.
@interface NDSessionRoot : HTTPVirtualDirectory {
 @private
  int nextId_;
}

// Creates a session and returns HTTPRedirectResponse toward the session's URL.
// |desiredCapabilities| will not used. |method| should be "POST" or "GET".
// If other method was passed, this returns nil.
- (id<HTTPResponse>)createSessionWithData:(id)desiredCapabilities
                                   method:(NSString*)method;

// Removes /session/:sessionId directory entry.
- (void)deleteSessionWithId:(int)sessionId;

@end

//
//  NDElementStore.h
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

@class NDElement, NDSession;

// This represents the /:session/element directory.
// All the elements are in /element/X where X is the element's id.
// This provides element finding feature and maintains element ids.
@interface NDElementStore : HTTPVirtualDirectory {
 @private
  NDSession* session_;  // the parent session (weak)
  NSMutableDictionary *elements_;
  int nextId_;
}

@property(nonatomic, readonly) NDSession *session;

// Makes an element store. Installs itself as the /element and /elements
// virtual directory handler for the given |session|. Note |session| is a weak
// pointer. The caller needs to ensure its lifetime outlives this object.
+ (NDElementStore *)elementStoreWithSession:(NDSession *)session;

// Finds one element from |root| element. |query| represents request JSON
// message. Returns a dictionary which represents response JSON message. The
// dictionary has "ELEMENT" key and element id as value. If |root| is nil, finds
// descendants of the default root.
- (NSDictionary *)findElement:(NSDictionary *)query
                         root:(NDElement *)root;

// Finds all elements from |root| element. |query| represents request JSON
// message. Returns an array which represents response JSON message. The array
// has dictionaries. Each dictionary has "ELEMENT" key and element id as value.
// If |root| is nil, finds descendants of the default root.
- (NSArray *)findElements:(NSDictionary *)query
                     root:(NDElement *)root;

@end

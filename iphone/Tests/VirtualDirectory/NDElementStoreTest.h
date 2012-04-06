//
//  NDElementStoreTest.h
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

#import "GTMSenTestCase.h"
#import "NDElementStore.h"

@class NDNativeElement;

// A Stub for |NDElementStore|. This stub overrides some methods for testing,
// doing nothing but saving method arguments to the properties for later
// verification.
@interface NDElementStoreStub : NDElementStore {
 @private
  NSString *by_;
  NSString *value_;
  NDElement *root_;
  NSUInteger maxCount_;
  NSMutableArray *results_;
  NDNativeElement *defaultNativeElement_;
}

@property(nonatomic, copy) NSString *by;
@property(nonatomic, copy) NSString *value;
@property(nonatomic, retain) NDElement *root;
@property(nonatomic) NSUInteger maxCount;
// An array of array. It contains multiple results for findElements.
// After n sleeps, The object at index n is used.
@property(nonatomic, retain) NSMutableArray *results;
@property(nonatomic, retain) NDNativeElement *defaultNativeElement;

- (void)addResult:(NSArray *)result;
- (NSDictionary *)contents;

@end

// Unit tests for |NDElementStore|.
@interface NDElementStoreTest : SenTestCase

@end

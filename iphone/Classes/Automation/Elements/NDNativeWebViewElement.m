//
//  NDNativeWebViewElement.m
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

#import "NDNativeWebViewElement.h"
#import "NDJavaScriptRunner.h"
#import "NDWebElement.h"

@implementation NDNativeWebViewElement

// Finds elements inside this element. Returns an array of |NDElement|.
- (NSArray *)findElementsBy:(NSString *)by
                      value:(NSString *)value
                   maxCount:(NSUInteger)maxCount {
  // Call |super| to find the WebView itself.
  NSArray *superResults = [super findElementsBy:by
                                         value:value
                                      maxCount:maxCount];

  // By text, by partial text, by placeholder are not supported in web view.
  // Returns only native world results.
  if ([NDElement isNativeOnlyStrategy:by]) {
    return superResults;
  }

  // Find inside DOM structure.
  NSUInteger remainCount = kFindEverything;
  if (maxCount != kFindEverything) {
    if ([superResults count] >= maxCount) {
      return superResults;
    }
    remainCount = maxCount - [superResults count];
  }
  UIWebView *webView = (UIWebView *)[self view];
  NSArray *webResults = [NDWebElement findElementsBy:by
                                               value:value
                                            maxCount:remainCount
                                             webView:webView];

  // Merge results.
  NSMutableArray *results = [NSMutableArray arrayWithArray:superResults];
  [results addObjectsFromArray:webResults];
  return results;
}

// We should find elements inside this view's DOM structure.
// we don't search inside UIView.
- (NSArray *)subElements {
  return [NSArray array];
}

@end

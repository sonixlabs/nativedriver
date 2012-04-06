//
//  NDNativeButtonElement.m
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

#import "NDNativeButtonElement.h"

@implementation NDNativeButtonElement

// |UIButton|'s text should be the text displayed on the button. |UIButton|
// itself doesn't provide text property, but we can get it via |titleLabel|
// property. Note |currentTitle| property might return incorrect title when user
// changes the |titleLabel| directly.
- (NSString *)text {
  return [[(UIButton *)[self view] titleLabel] text];
}

// |UIButton| has children, but WebDriver API assumes a button is one element.
// We treat the element and its children as one element, so that users can
// easily find element and get attributes.
- (NSArray *)subElements {
  return [NSArray array];
}

@end

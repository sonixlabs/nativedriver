//
//  NDNativeTextElement.h
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

#import "NDNativeElement.h"

// Wraps text-field like elements in the target application. This is an abstract
// class.
@interface NDNativeTextElement : NDNativeElement

// Returns true if the view should send |textFieldShouldReturn:| message for the
// given key.
- (BOOL)isTextFieldReturnKey:(NSString *)key;

// Sends |textFieldShouldReturn:| message to the delegate. Just returns YES if
// the element doesn't support this message.
- (BOOL)shouldReturn;

// Tells the delegate it should change the text in range. Just returns YES if
// the element doesn't support checking changes.
- (BOOL)shouldChangeTextInRange:(NSRange)range
              replacementString:(NSString *)text;

// Sends |textViewDidChange:| message to the delegate. Does nothing if the
// element doesn't support this message.
- (void)didChange;

@end


//
//  NDNativeTextFieldElement.m
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

#import "NDNativeTextFieldElement.h"

@implementation NDNativeTextFieldElement

// Returns true if the view should send |textFieldShouldReturn:| message for the
// given key.
- (BOOL)isTextFieldReturnKey:(NSString *)key {
  return [key isEqualToString:@"\n"];
}

// Sends |textFieldShouldReturn:| message to the delegate.
- (BOOL)shouldReturn {
  UITextField *textField = (UITextField *)[self view];
  id<UITextFieldDelegate> delegate = [textField delegate];
  if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
    return [delegate textFieldShouldReturn:textField];
  }
  return YES;
}

// Tells the delegate it should change the text in range.
- (BOOL)shouldChangeTextInRange:(NSRange)range
              replacementString:(NSString *)text {
  UITextField *textField = (UITextField *)[self view];
  id<UITextFieldDelegate> delegate = [textField delegate];
  if ([delegate respondsToSelector:
       @selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
    return [delegate textField:textField
                     shouldChangeCharactersInRange:range
                     replacementString:text];
  }
  return YES;
}

@end

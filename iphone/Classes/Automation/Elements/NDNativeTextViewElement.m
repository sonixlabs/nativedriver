//
//  NDNativeTextViewElement.m
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

#import "NDNativeTextViewElement.h"

@implementation NDNativeTextViewElement

// Tells the delegate it should change the text in range.
- (BOOL)shouldChangeTextInRange:(NSRange)range
              replacementString:(NSString *)text {
  UITextView *textView = (UITextView *)[self view];
  id<UITextViewDelegate> delegate = [textView delegate];
  if ([delegate respondsToSelector:
       @selector(textView:shouldChangeTextInRange:replacementText:)]) {
    return [delegate textView:textView
                     shouldChangeTextInRange:range
                     replacementText:text];
  }
  return YES;
}

// Sends |textViewDidChange:| message to the delegate.
- (void)didChange {
  UITextView *textView = (UITextView *)[self view];
  id<UITextViewDelegate> delegate = [textView delegate];
  if ([delegate respondsToSelector:@selector(textViewDidChange:)]) {
    return [delegate textViewDidChange:textView];
  }
}

@end

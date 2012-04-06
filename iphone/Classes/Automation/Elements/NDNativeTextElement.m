//
//  NDNativeTextElement.m
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

#import "NDNativeTextElement.h"

#import "errorcodes.h"
#import "NSException+WebDriver.h"

@interface NDNativeTextElement ()

- (void)doSendKeys:(NSString *)text;

- (void)doClear;

@end

@implementation NDNativeTextElement

// Sends keys to this element. |array| should contain strings to send.
- (void)sendKeys:(NSArray *)array {
  NSString *stringToType = [array componentsJoinedByString:@""];
  [self performSelectorOnMainThread:@selector(doSendKeys:)
                         withObject:stringToType
                      waitUntilDone:YES];
}

// Clears the text in this element.
- (void)clear {
  [self performSelectorOnMainThread:@selector(doClear)
                         withObject:nil
                      waitUntilDone:YES];
}

// |UITextField| and |UITextView| have children, but WebDriver API assumes text
// field is one element. We treat the element and its children as one element,
// so that users can easily find element and send keys in it.
- (NSArray *)subElements {
  return [NSArray array];
}

// Sets text of the view.
- (void)setText:(NSString *)text {
  // [self view] should be a |UITextField| or a |UITextView|. Both of them
  // respond to |setText:|. We cast it to |id| to supress warning.
  [(id)[self view] setText:text];
}

// Returns true if the view should send |textFieldShouldReturn:| message for the
// given key.
- (BOOL)isTextFieldReturnKey:(NSString *)key {
  return NO;
}

// Sends |textFieldShouldReturn:| message to the delegate. Just returns YES if
// the element doesn't support this message.
- (BOOL)shouldReturn {
  return YES;
}

// Tells the delegate it should change the text in range. Just returns YES if
// the element doesn't support checking changes.
- (BOOL)shouldChangeTextInRange:(NSRange)range
              replacementString:(NSString *)text {
  return YES;
}

// Sends |textViewDidChange:| message to the delegate. Does nothing if the
// element doesn't support this message.
- (void)didChange {
  // do nothing
}

// Sets focus to this element.
- (void)becomeFirstResponderOrThrowException {
  if ([[self view] canBecomeFirstResponder]) {
    [[self view] becomeFirstResponder];
  } else {
    @throw [NSException
        webDriverExceptionWithMessage:@"The view can't become first responder."
                        andStatusCode:EUNHANDLEDERROR];
  }
}

// Sends keys to this element. This method should work on main thread.
- (void)doSendKeys:(NSString *)text {
  [self becomeFirstResponderOrThrowException];

  // type the text
  for (int i=0; i < [text length]; i++) {
    NSString *key = [text substringWithRange:NSMakeRange(i, 1)];
    NSRange range = NSMakeRange([[self text] length], 0);
    if ([self isTextFieldReturnKey:key]) {
      // Return is a special key. textFieldShouldReturn should be called.
      [self shouldReturn];
    } else {
      // update text
      if ([self shouldChangeTextInRange:range
                      replacementString:key]) {
        [self setText:[NSString stringWithFormat:@"%@%@", [self text], key]];
        [self didChange];
      }
    }
  }
}

// Clears the contents of this element. This method should work on main thread.
- (void)doClear {
  [self becomeFirstResponderOrThrowException];

  // clear the text if necessary
  if ([[self text] length] > 0) {
    NSRange range = NSMakeRange(0, [[self text] length]);
    if ([self shouldChangeTextInRange:range replacementString:@""]) {
      [self setText:@""];
      [self didChange];
    }
  }
}

@end

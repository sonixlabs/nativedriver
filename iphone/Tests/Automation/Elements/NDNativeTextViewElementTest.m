//
//  NDNativeTextViewElementTest.m
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

#import "NDNativeTextViewElementTest.h"

#import "NDNativeTextViewElement.h"
#import "OCMock/OCMock.h"

@interface TextViewDelegateStub : NSObject<UITextViewDelegate> {
 @private
  int shouldChangeTextCalled_;
  int didChangeCalled_;
  BOOL returnValue_;
}

@property(nonatomic) int shouldChangeTextCalled;
@property(nonatomic) int didChangeCalled;
@property(nonatomic) BOOL returnValue;

@end

@implementation TextViewDelegateStub

@synthesize shouldChangeTextCalled = shouldChangeTextCalled_;
@synthesize didChangeCalled = didChangeCalled_;
@synthesize returnValue = returnValue_;

- (BOOL)textView:(UITextView *)textView
        shouldChangeTextInRange:(NSRange)range
        replacementText:(NSString *)text {
  shouldChangeTextCalled_++;
  return returnValue_;
}

- (void)textViewDidChange:(UITextView *)textView {
  didChangeCalled_++;
}

@end

@implementation NDNativeTextViewElementTest

// setText should be called for each charactor.
- (void)testSendKeys {
  id textView = [OCMockObject mockForClass:[UITextView class]];
  NDNativeTextViewElement *element =
      [[[NDNativeTextViewElement alloc] initWithView:textView] autorelease];

  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];
  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      becomeFirstResponder];
  [[[textView stub] andReturn:nil] delegate];
  [[[textView stub] andReturn:@"..."] valueForKey:@"text"];
  [[textView expect] setText:@"...a"];
  [[textView expect] setText:@"...b"];
  [[textView expect] setText:@"...c"];
  [[textView expect] setText:@"...d"];

  [element sendKeys:[NSArray arrayWithObjects:@"ab", @"cd", nil]];

  [textView verify];
}

// Should throw WebDriver Exception if the element can't become first responder.
- (void)testSendKeysCannotBecomeFirstResponder {
  id textView = [OCMockObject mockForClass:[UITextView class]];
  NDNativeTextViewElement *element =
      [[[NDNativeTextViewElement alloc] initWithView:textView] autorelease];

  [[[textView stub] andReturnValue:[NSNumber numberWithBool:NO]]
      canBecomeFirstResponder];

  @try {
    [element sendKeys:[NSArray arrayWithObjects:@"ab", @"cd", nil]];
    STFail(@"Should throw exception.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings([exception name], @"kWebDriverException",
                         @"Should throw WebDriver Exception.");
  }

  [textView verify];
}

// Should call delegate's event listeners.
- (void)testSendKeysDelegateCalled {
  id textView = [OCMockObject mockForClass:[UITextView class]];
  NDNativeTextViewElement *element =
      [[[NDNativeTextViewElement alloc] initWithView:textView] autorelease];
  TextViewDelegateStub *delegate =
      [[[TextViewDelegateStub alloc] init] autorelease];
  [delegate setReturnValue:YES];

  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];
  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      becomeFirstResponder];
  [[[textView stub] andReturn:delegate] delegate];
  [[[textView stub] andReturn:@""] valueForKey:@"text"];
  [[textView expect] setText:@"x"];
  [[textView expect] setText:@"y"];
  [[textView expect] setText:@"z"];

  [element sendKeys:[NSArray arrayWithObject:@"xyz"]];

  [textView verify];
  STAssertEquals(3, [delegate shouldChangeTextCalled],
                 @"shouldChangeCharacters should be called.");
  STAssertEquals(3, [delegate didChangeCalled],
                 @"textFieldShouldReturn should be called.");
}

// Should call delegate's event listeners. If |shouldChangeCharacters| returns
// NO, should not change the text.
- (void)testSendKeysDelegateCalledAndReturnNO {
  id textView = [OCMockObject mockForClass:[UITextView class]];
  NDNativeTextViewElement *element =
      [[[NDNativeTextViewElement alloc] initWithView:textView] autorelease];
  TextViewDelegateStub *delegate =
      [[[TextViewDelegateStub alloc] init] autorelease];
  [delegate setReturnValue:NO];

  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];
  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      becomeFirstResponder];
  [[[textView stub] andReturn:delegate] delegate];
  [[[textView stub] andReturn:@""] valueForKey:@"text"];
  // setText won't be called.

  [element sendKeys:[NSArray arrayWithObject:@"xyz"]];

  [textView verify];
  STAssertEquals(3, [delegate shouldChangeTextCalled],
                 @"shouldChangeCharacters should be called.");
  STAssertEquals(0, [delegate didChangeCalled],
                 @"textFieldShouldReturn should be called.");
}

// Should clear text.
- (void)testClear {
  id textView = [OCMockObject mockForClass:[UITextView class]];
  NDNativeTextViewElement *element =
      [[[NDNativeTextViewElement alloc] initWithView:textView] autorelease];
  TextViewDelegateStub *delegate =
      [[[TextViewDelegateStub alloc] init] autorelease];

  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
   canBecomeFirstResponder];
  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
   becomeFirstResponder];
  [[[textView stub] andReturn:@"SomeText"] valueForKey:@"text"];
  [[[textView stub] andReturn:delegate] delegate];
  [delegate setReturnValue:YES];
  [[textView expect] setText:@""];

  [element clear];

  [textView verify];
  STAssertEquals(1, [delegate shouldChangeTextCalled],
                 @"shouldChangeCharacters should not be called.");
  STAssertEquals(1, [delegate didChangeCalled],
                 @"textFieldShouldReturn should be called.");
}

// Should throw WebDriver Exception if the element can't become first responder.
- (void)testClearCannotBecomeFirstResponder {
  id textView = [OCMockObject mockForClass:[UITextView class]];
  NDNativeTextViewElement *element =
      [[[NDNativeTextViewElement alloc] initWithView:textView] autorelease];

  [[[textView stub] andReturnValue:[NSNumber numberWithBool:NO]]
   canBecomeFirstResponder];

  @try {
    [element clear];
    STFail(@"Should throw exception.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings([exception name], @"kWebDriverException",
                         @"Should throw WebDriver Exception.");
  }

  [textView verify];
}

// Should call delegate's |shouldReturn|.
- (void)testSubmit {
  id textView = [OCMockObject mockForClass:[UITextView class]];
  NDNativeTextViewElement *element =
      [[[NDNativeTextViewElement alloc] initWithView:textView] autorelease];
  TextViewDelegateStub *delegate =
      [[[TextViewDelegateStub alloc] init] autorelease];
  [delegate setReturnValue:YES];

  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];
  [[[textView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      becomeFirstResponder];
  [[[textView stub] andReturn:delegate] delegate];
  [[[textView stub] andReturn:@""] valueForKey:@"text"];
  [[textView expect] setText:@"\n"];

  [element submit];

  [textView verify];
  STAssertEquals(1, [delegate shouldChangeTextCalled],
                 @"shouldChangeCharacters should not be called.");
  STAssertEquals(1, [delegate didChangeCalled],
                 @"textFieldShouldReturn should be called.");
}

// Should throw WebDriver Exception if the element can't become first responder.
- (void)testSubmitCannotBecomeFirstResponder {
  id textView = [OCMockObject mockForClass:[UITextView class]];
  NDNativeTextViewElement *element =
      [[[NDNativeTextViewElement alloc] initWithView:textView] autorelease];

  [[[textView stub] andReturnValue:[NSNumber numberWithBool:NO]]
      canBecomeFirstResponder];

  @try {
    [element submit];
    STFail(@"Should throw exception.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings([exception name], @"kWebDriverException",
                         @"Should throw WebDriver Exception.");
  }

  [textView verify];
}

@end

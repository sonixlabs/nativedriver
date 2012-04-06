//
//  NDNativeTextFieldElementTest.m
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

#import "NDNativeTextFieldElementTest.h"

#import "NDNativeTextFieldElement.h"
#import "OCMock/OCMock.h"

@interface TextFieldDelegateStub : NSObject<UITextFieldDelegate> {
 @private
  int shouldChangeCharactersCalled_;
  int shouldReturnCalled_;
  BOOL returnValue_;
}

@property(nonatomic) int shouldChangeCharactersCalled;
@property(nonatomic) int shouldReturnCalled;
@property(nonatomic) BOOL returnValue;

@end

@implementation TextFieldDelegateStub

@synthesize shouldChangeCharactersCalled = shouldChangeCharactersCalled_;
@synthesize shouldReturnCalled = shouldReturnCalled_;
@synthesize returnValue = returnValue_;

- (BOOL)textField:(UITextField *)textField
        shouldChangeCharactersInRange:(NSRange)range
        replacementString:(NSString *)text {
  shouldChangeCharactersCalled_++;
  return returnValue_;
}

- (BOOL)textFieldShouldReturn:textField {
  shouldReturnCalled_++;
  return YES;
}

@end

@implementation NDNativeTextFieldElementTest

// setText should be called for each charactor.
- (void)testSendKeys {
  id textField = [OCMockObject mockForClass:[UITextField class]];
  NDNativeTextFieldElement *element =
      [[[NDNativeTextFieldElement alloc] initWithView:textField] autorelease];

  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];
  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
      becomeFirstResponder];
  [[[textField stub] andReturn:nil] delegate];
  [[[textField stub] andReturn:@"..."] valueForKey:@"text"];
  [[textField expect] setText:@"...a"];
  [[textField expect] setText:@"...b"];
  [[textField expect] setText:@"...c"];
  [[textField expect] setText:@"...d"];

  [element sendKeys:[NSArray arrayWithObjects:@"ab", @"cd", nil]];

  [textField verify];
}

// Should throw WebDriver Exception if the element can't become first responder.
- (void)testSendKeysCannotBecomeFirstResponder {
  id textField = [OCMockObject mockForClass:[UITextField class]];
  NDNativeTextFieldElement *element =
      [[[NDNativeTextFieldElement alloc] initWithView:textField] autorelease];

  [[[textField stub] andReturnValue:[NSNumber numberWithBool:NO]]
      canBecomeFirstResponder];

  @try {
    [element sendKeys:[NSArray arrayWithObjects:@"ab", @"cd", nil]];
    STFail(@"Should throw exception.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings([exception name], @"kWebDriverException",
                         @"Should throw WebDriver Exception.");
  }

  [textField verify];
}

// Should call delegate's event listeners.
- (void)testSendKeysDelegateCalled {
  id textField = [OCMockObject mockForClass:[UITextField class]];
  NDNativeTextFieldElement *element =
      [[[NDNativeTextFieldElement alloc] initWithView:textField] autorelease];
  TextFieldDelegateStub *delegate =
      [[[TextFieldDelegateStub alloc] init] autorelease];
  [delegate setReturnValue:YES];

  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];
  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
      becomeFirstResponder];
  [[[textField stub] andReturn:delegate] delegate];
  [[[textField stub] andReturn:@""] valueForKey:@"text"];
  [[textField expect] setText:@"x"];
  [[textField expect] setText:@"y"];
  [[textField expect] setText:@"z"];

  [element sendKeys:[NSArray arrayWithObject:@"xyz\n\n"]];

  [textField verify];
  STAssertEquals(3, [delegate shouldChangeCharactersCalled],
                 @"shouldChangeCharacters should be called.");
  STAssertEquals(2, [delegate shouldReturnCalled],
                 @"textFieldShouldReturn should be called.");
}

// Should call delegate's event listeners. If |shouldChangeCharacters| returns
// NO, should not change the text.
- (void)testSendKeysDelegateCalledAndReturnNO {
  id textField = [OCMockObject mockForClass:[UITextField class]];
  NDNativeTextFieldElement *element =
      [[[NDNativeTextFieldElement alloc] initWithView:textField] autorelease];
  TextFieldDelegateStub *delegate =
      [[[TextFieldDelegateStub alloc] init] autorelease];
  [delegate setReturnValue:NO];

  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];
  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
      becomeFirstResponder];
  [[[textField stub] andReturn:delegate] delegate];
  [[[textField stub] andReturn:@""] valueForKey:@"text"];
  // setText won't be called.

  [element sendKeys:[NSArray arrayWithObject:@"xyz\n\n"]];

  [textField verify];
  STAssertEquals(3, [delegate shouldChangeCharactersCalled],
                 @"shouldChangeCharacters should be called.");
  STAssertEquals(2, [delegate shouldReturnCalled],
                 @"textFieldShouldReturn should be called.");
}

// Should clear text.
- (void)testClear {
  id textField = [OCMockObject mockForClass:[UITextField class]];
  NDNativeTextFieldElement *element =
      [[[NDNativeTextFieldElement alloc] initWithView:textField] autorelease];
  TextFieldDelegateStub *delegate =
      [[[TextFieldDelegateStub alloc] init] autorelease];

  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
   canBecomeFirstResponder];
  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
   becomeFirstResponder];
  [[[textField stub] andReturn:@"SomeText"] valueForKey:@"text"];
  [[[textField stub] andReturn:delegate] delegate];
  [delegate setReturnValue:YES];
  [[textField expect] setText:@""];

  [element clear];

  [textField verify];
  STAssertEquals(1, [delegate shouldChangeCharactersCalled],
                 @"shouldChangeCharacters should not be called.");
  STAssertEquals(0, [delegate shouldReturnCalled],
                 @"textFieldShouldReturn should be called.");
}

// Should throw WebDriver Exception if the element can't become first responder.
- (void)testClearCannotBecomeFirstResponder {
  id textField = [OCMockObject mockForClass:[UITextField class]];
  NDNativeTextFieldElement *element =
      [[[NDNativeTextFieldElement alloc] initWithView:textField] autorelease];

  [[[textField stub] andReturnValue:[NSNumber numberWithBool:NO]]
      canBecomeFirstResponder];

  @try {
    [element clear];
    STFail(@"Should throw exception.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings([exception name], @"kWebDriverException",
                         @"Should throw WebDriver Exception.");
  }

  [textField verify];
}

// Should call delegate's |shouldReturn|.
- (void)testSubmit {
  id textField = [OCMockObject mockForClass:[UITextField class]];
  NDNativeTextFieldElement *element =
      [[[NDNativeTextFieldElement alloc] initWithView:textField] autorelease];
  TextFieldDelegateStub *delegate =
      [[[TextFieldDelegateStub alloc] init] autorelease];

  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];
  [[[textField stub] andReturnValue:[NSNumber numberWithBool:YES]]
      becomeFirstResponder];
  [[[textField stub] andReturn:delegate] delegate];
  [[[textField stub] andReturn:@""] valueForKey:@"text"];

  [element submit];

  [textField verify];
  STAssertEquals(0, [delegate shouldChangeCharactersCalled],
                 @"shouldChangeCharacters should not be called.");
  STAssertEquals(1, [delegate shouldReturnCalled],
                 @"textFieldShouldReturn should be called.");
}

// Should throw WebDriver Exception if the element can't become first responder.
- (void)testSubmitCannotBecomeFirstResponder {
  id textField = [OCMockObject mockForClass:[UITextField class]];
  NDNativeTextFieldElement *element =
      [[[NDNativeTextFieldElement alloc] initWithView:textField] autorelease];

  [[[textField stub] andReturnValue:[NSNumber numberWithBool:NO]]
      canBecomeFirstResponder];

  @try {
    [element submit];
    STFail(@"Should throw exception.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings([exception name], @"kWebDriverException",
                         @"Should throw WebDriver Exception.");
  }

  [textField verify];
}

@end

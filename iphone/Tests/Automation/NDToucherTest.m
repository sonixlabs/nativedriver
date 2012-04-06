//
//  NDToucherTest.m
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

#import "NDToucherTest.h"

#import "NDToucher.h"
#import "OCMock/OCMock.h"

@implementation NDToucherTest

// |touchesBegan|, |touchesEnded|, and |becomeFirstResponder| should be called
// for the topmost view on the point.
- (void)testTouch {
  id any = [[[OCMAnyConstraint alloc] init] autorelease];
  CGRect rect = CGRectMake(0.0, 0.0, 10.0, 10.0);
  CGPoint point = CGPointMake(5.0, 5.0);
  id view = [OCMockObject mockForClass:[UIView class]];
  id window = [OCMockObject mockForClass:[UIWindow class]];
  id hitView = [OCMockObject mockForClass:[UIView class]];

  [[[view stub] andReturn:nil] superview];
  [[[view stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[UIWindow class]];
  [[[view stub] andReturn:window] window];
  [[[view stub] andReturnValue:[NSValue valueWithCGRect:rect]] frame];
  [[[window stub] andReturnValue:[NSValue valueWithCGRect:rect]]
      convertRect:rect fromView:nil];
  [[[window stub] andReturn:hitView] hitTest:point withEvent:nil];
  [[[window stub] andReturnValue:[NSValue valueWithCGPoint:point]]
      convertPoint:point fromView:window];
  [[[hitView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      canBecomeFirstResponder];

  // Expects |touchesBegan|, |touchesEnded|, and |becomeFirstResponder|.
  [[hitView expect] touchesBegan:any withEvent:any];
  [[hitView expect] touchesEnded:any withEvent:any];
  [[hitView expect] becomeFirstResponder];

  // Run.
  [NDToucher touch:view];

  // Verify all messages were sent.
  [view verify];
  [window verify];
  [hitView verify];
}

// |scrollRectToVisible| should be called.
- (void)testScroll {
  CGRect rect = CGRectMake(0.0, 0.0, 10.0, 10.0);
  id view = [OCMockObject mockForClass:[UIView class]];
  id scrollView = [OCMockObject mockForClass:[UIScrollView class]];

  [[[view stub] andReturn:scrollView] superview];
  [[[view stub] andReturnValue:[NSNumber numberWithBool:NO]]
      isKindOfClass:[UIWindow class]];
  [[[view stub] andReturn:nil] window];
  [[[view stub] andReturnValue:[NSValue valueWithCGRect:rect]] frame];
  [[[view stub] andReturnValue:[NSValue valueWithCGRect:rect]] bounds];
  [[[view stub] andReturnValue:[NSValue valueWithCGRect:rect]]
      convertRect:rect toView:scrollView];
  [[[scrollView stub] andReturnValue:[NSNumber numberWithBool:YES]]
      isKindOfClass:[UIScrollView class]];
  [[[scrollView stub] andReturn:nil] superview];

  // Expects |scrollRectToVisible|.
  [[scrollView expect] scrollRectToVisible:rect animated:YES];

  // Run.
  [NDToucher touch:view];

  // Verify all messages were sent.
  [view verify];
  [scrollView verify];
}

@end

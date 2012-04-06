//
//  NDToucher.m
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

#import "NDToucher.h"
#import "TouchSynthesis.h"

@interface NDToucher ()

- (void)performTouch:(UIView *)view;
- (void)scrollToVisible:(UIView *)view;

@end

@implementation NDToucher

// Sends touch event to specified view.
+ (void)touch:(UIView *)view {
  NDToucher *toucher = [[[NDToucher alloc] init] autorelease];
  [toucher performSelectorOnMainThread:@selector(performTouch:)
                            withObject:view
                         waitUntilDone:YES];
}

// Sends touch event to specified view. This method should be executed on main
// thread.
- (void)performTouch:(UIView *)view {
  // Make the view visible.
  [self scrollToVisible:view];

  // Create touch event for the view. Note [touch view] has the topmost element
  // in the window. Tap event should be sent to the topmost element, not to the
  // specified view.
  UITouch *touch = [[[UITouch alloc] initInView:view] autorelease];

  // The view should get focused.
  if ([[touch view] canBecomeFirstResponder]) {
    [[touch view] becomeFirstResponder];
  }

  // Send touchesBegan and touchesEnded messages.
  NSSet *touches = [NSSet setWithObject:touch];
  UIEvent *event = [[[NSClassFromString(@"UITouchesEvent") alloc]
                     initWithTouch:touch] autorelease];
  [[touch view] touchesBegan:touches withEvent:event];
  [touch setPhase:UITouchPhaseEnded];
  [[touch view] touchesEnded:touches withEvent:event];
}

// Scroll the |UIScrollView|s to display |view| on the screen.
- (void)scrollToVisible:(UIView *)view {
  UIView *parent = [view superview];
  while (parent) {
    if ([parent isKindOfClass:[UIScrollView class]]) {
      UIScrollView *scrollView = (UIScrollView *)parent;
      CGRect rect = [view convertRect:[view bounds] toView:scrollView];
      [scrollView scrollRectToVisible:rect animated:YES];
    }
    parent = [parent superview];
  }
}

@end

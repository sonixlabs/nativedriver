//
//  NDNativeElement.m
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

#import "errorcodes.h"
#import "NDNativeElement.h"
#import "NDNativeButtonElement.h"
#import "NDNativeSwitchElement.h"
#import "NDNativeTextFieldElement.h"
#import "NDNativeTextViewElement.h"
#import "NDNativeWebViewElement.h"
#import "NDMainThreadRunner.h"
#import "NDToucher.h"
#import "NSException+WebDriver.h"

@interface NDNativeElement ()

- (BOOL)matchesBy:(NSString *)by value:(NSString *)value;
- (NSString *)performAttribute:(NSString *)name;

@end

@implementation NDNativeElement

@synthesize view = view_;

- (id)initWithView:(UIView*)view {
  if ((self = [super init])) {
    view_ = [view retain];
  }
  return self;
}

- (void)dealloc {
  [view_ release];
  [super dealloc];
}

// Creates new element wrapping |UIView|.
+ (NDNativeElement *)elementWithView:(UIView *)view {
  if ([view isKindOfClass:[UIButton class]]) {
    return [[[NDNativeButtonElement alloc] initWithView:view] autorelease];
  }
  if ([view isKindOfClass:[UISwitch class]]) {
    return [[[NDNativeSwitchElement alloc] initWithView:view] autorelease];
  }
  if ([view isKindOfClass:[UITextField class]]) {
    return [[[NDNativeTextFieldElement alloc] initWithView:view] autorelease];
  }
  if ([view isKindOfClass:[UITextView class]]) {
    return [[[NDNativeTextViewElement alloc] initWithView:view] autorelease];
  }
  if ([view isKindOfClass:[UIWebView class]]) {
    return [[[NDNativeWebViewElement alloc] initWithView:view] autorelease];
  }
  return [[[NDNativeElement alloc] initWithView:view] autorelease];
}

#pragma mark NDNativeElement Methods

// Returns accesibility label if accesibility is enabled and label is set.
// Otherwise returns nil.
- (NSString *)elementId {
  return [view_ accessibilityLabel];
}

// Returns an array of |NDNativeElement| representing child |UIView|s.
- (NSArray *)subElements {
  NSMutableArray *result =
      [NSMutableArray arrayWithCapacity:[[view_ subviews] count]];
  for (UIView *subview in [view_ subviews]) {
    [result addObject:[NDNativeElement elementWithView:subview]];
  }
  return result;
}

// Checks if the specified element matches the condition or not.
- (BOOL)matchesBy:(NSString *)by value:(NSString *)value {
  if ([by isEqualToString:kById]) {
    return [value isEqualToString:[self elementId]];
  } else if ([by isEqualToString:kByText]) {
    return [value isEqualToString:[self text]];
  } else if ([by isEqualToString:kByPartialText]) {
    return ([self text]
            && ([[self text] rangeOfString:value].location != NSNotFound));
  } else if ([by isEqualToString:kByClassName]) {
    return [[self view] isKindOfClass:NSClassFromString(value)];
  } else if ([by isEqualToString:kByPlaceholder]) {
    return [value isEqualToString:[self attribute:kPlaceholderAttribute]];
  } else if ([NDElement isWebOnlyStrategy:by]) {
    // Not supported in native world, but they might be used in the web view
    // inside this element.
    return NO;
  }
  NSString *message =
      [NSString stringWithFormat:@"Unsupported strategy: %@", by];
  @throw [NSException webDriverExceptionWithMessage:message
                                      andStatusCode:EUNHANDLEDERROR];
}

// Returns the value of the attribute, or nil if it is not set on the element.
// This method should be called in main thread.
- (NSString *)performAttribute:(NSString *)name {
  @try {
    // call description to convert value to NSString.
    return [[view_ valueForKey:name] description];
  }
  @catch (NSException *exception) {
    // valueForKey throws NSException if the key does not exist.
    // TODO(tkaizu): only catch NSUndefinedKeyException
    return nil;
  }
}

#pragma mark NDElement Methods

// Returns the value of the attribute, or nil if it is not set on the element.
- (NSString *)attribute:(NSString *)name {
  // Accessing some attributes in UIKit needs to run on main thread.
  return [NDMainThreadRunner performSelector:@selector(performAttribute:)
                                        args:name
                                      target:self];
}

// Simulates tap.
- (void)click {
  [NDToucher touch:view_];
}

// Finds elements inside this element. Returns an array of |NDElement|.
- (NSArray *)findElementsBy:(NSString *)by
                      value:(NSString *)value
                   maxCount:(NSUInteger)maxCount {
  NSMutableArray *results = [NSMutableArray array];
  if ([self matchesBy:by value:value]) {
    [results addObject:self];
  }
  for (NDNativeElement *subElement in [self subElements]) {
    NSUInteger remainCount = kFindEverything;
    if (maxCount != kFindEverything) {
      if ([results count] >= maxCount) {
        break;
      }
      remainCount = maxCount - [results count];
    }
    [results addObjectsFromArray:[subElement findElementsBy:by
                                                      value:value
                                                   maxCount:remainCount]];
  }
  return results;
}

// Returns YES if the |UIWebView| is on the key window. NativeDriver should not
// drive the target if this method returns NO.
//
// There are two reasons why this method will return NO:
// 1. The target's |window| property returns nil. In this case, the window has
// already disappeared from the display.
// 2. The containing window is not the key window. In this case, other window
// such as a dialog box is waiting for input.
- (BOOL)isAlive {
  // If view_ is a window, [view_ window] returns nil.
  if ([view_ isKindOfClass:[UIWindow class]]) {
    return [(UIWindow *)view_ isKeyWindow];
  }
  return [[view_ window] isKeyWindow];
}

// Returns NO if this element or any ancestor is hidden.
- (BOOL)isDisplayed {
  UIView *view = view_;
  while (view != nil) {
    if ([view isHidden]) {
      return NO;
    }
    view = view.superview;
  }
  return YES;
}

// Returns YES if this element is enabled. If the view is not |UIControl|, This
// method always return YES.
- (BOOL)isEnabled {
  if ([view_ isKindOfClass:[UIControl class]]) {
    return [(UIControl *)view_ isEnabled];
  }
  return YES;
}

// Returns the class name.
- (NSString *)tagName {
  return [[view_ class] description];
}

// Returns "text" or "title" property of this element. For example, UILabel has
// "text" property to get displayed text, and UIButton has "title" property to
// get displayed text. This method supports both patterns.
- (NSString *)text {
  NSString *text = [self attribute:@"text"];
  if (text) {
    return text;
  }
  return [self attribute:@"title"];
}

@end

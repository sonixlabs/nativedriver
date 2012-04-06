//
//  NDNativeElement.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NDElement.h"

// Wraps an |UIView| element in the target application and provides WebDriver
// features.
@interface NDNativeElement : NDElement {
 @private
  UIView* view_;
}

@property(nonatomic, readonly) UIView *view;

// Initializes new instance for |UIView|. Subclasses should call this.
- (id)initWithView:(UIView *)view;

// Creates new instance for |UIView|.
+ (NDNativeElement *)elementWithView:(UIView *)view;

// Returns accessibility label if the accesibility API is enabled and the label
// is set. Otherwise returns nil.
- (NSString *)elementId;

// Returns an array of |NDNativeElement| representing child |UIView|s.
- (NSArray *)subElements;

@end


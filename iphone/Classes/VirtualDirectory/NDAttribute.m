//
//  NDAttribute.m
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

#import "NDAttribute.h"

#import "NDElement.h"
#import "NDSession.h"
#import "WebDriverResource.h"

// Private methods for NDAttribute.
@interface NDAttribute ()

- (id)initWithElement:(NDElement *)element;

@end

// Represents the /:session/element/:id/attribute/:name directory. These
// directories will be generated and registered dynamically as they are
// requested. This class is private because it is tiny and only used by
// |elementWithQuery:| in |NDAttribute|.
@interface NDNamedAttribute : HTTPVirtualDirectory {
 @private
  NDElement *element_;
  NSString *attributeName_;
}

- (id)initWithElement:(NDElement *)element
        attributeName:(NSString *)attributeName;

- (NSString *)attribute;

@end

@implementation NDAttribute

// Initialize a new element.
- (id)initWithElement:(NDElement *)element {
  if ((self = [super init])) {
    element_ = [element retain];
  }
  return self;
}

// Release object.
- (void)dealloc {
  [element_ release];
  [super dealloc];
}

// Create a new element.
+ (NDAttribute *)attributeForElement:(NDElement *)element {
  return [[[NDAttribute alloc] initWithElement:element] autorelease];
}

// Override to fetch the sub-resource for this relative query string.
- (id<HTTPResource>)elementWithQuery:(NSString *)query {
  if ([query length] <= 1) {
    // The behaviors for ".../attribute" or ".../attribute/" are not defined.
    return nil;
  }
  // Remove '/' in front of the query.
  NSString *attributeName = [query substringFromIndex:1];
  if (![contents objectForKey:attributeName]) {
    // If no resource is registered, creates new one.
    NDNamedAttribute *resource =
        [[[NDNamedAttribute alloc] initWithElement:element_
                                     attributeName:attributeName] autorelease];
    [self setResource:resource withName:attributeName];
  }
  // Call |super| to enables |NDSession| to inject session id.
  return [super elementWithQuery:query];
}

@end

@implementation NDNamedAttribute

// Initialize a new element.
- (id)initWithElement:(NDElement *)element
        attributeName:(NSString *)attributeName {
  if ((self = [super init])) {
    element_ = [element retain];
    attributeName_ = [attributeName copy];

    [self setIndex:[WebDriverResource resourceWithTarget:self
                                               GETAction:@selector(attribute)
                                              POSTAction:nil]];
  }
  return self;
}

// Release object.
- (void)dealloc {
  [element_ release];
  [attributeName_ release];
  [super dealloc];
}

// Return attribute value.
- (NSString *)attribute {
  return [element_ attribute:attributeName_];
}

@end

//
//  NDElementDirectory.m
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

#import "NDElementDirectory.h"

#import "errorcodes.h"
#import "NDAttribute.h"
#import "NDElement.h"
#import "NDElementStore.h"
#import "NSException+WebDriver.h"
#import "WebDriverResource.h"

@interface NDElementDirectory ()

// Initializer
- (id)initWithElement:(NDElement *)element
         elementStore:(NDElementStore *)elementStore;

// Actions for the requests. Each method checks the target's state.
// Potential errors are defined in:
//   http://code.google.com/p/selenium/wiki/JsonWireProtocol
- (void)clear:(NSDictionary*)ignored;
- (void)click:(NSDictionary*)ignored;
- (NSDictionary *)findElement:(NSDictionary*)query;
- (NSArray *)findElements:(NSDictionary*)query;
- (NSNumber *)isDisplayed;
- (NSNumber *)isSelected;
- (NSNumber *)isEnabled;
- (void)sendKeys:(NSDictionary *)dict;
- (void)submit:(NSDictionary *)ignored;
- (NSString *)tagName;
- (NSString *)text;

// Verifiers of the element state.
- (void)verifyElementStillAlive;
- (void)verifyElementSelectable;
- (void)verifyElementVisible;
- (void)verifyElementEnabled;

@end

@implementation NDElementDirectory

// Initializes an element store. Prepare resources to handle element-related
// requests.
- (id)initWithElement:(NDElement *)element
         elementStore:(NDElementStore *)elementStore {
  if ((self = [super init])) {
    element_ = [element retain];
    elementStore_ = elementStore;

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:nil
                               POSTAction:@selector(clear:)]
             withName:@"clear"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:nil
                               POSTAction:@selector(click:)]
             withName:@"click"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:@selector(isDisplayed)
                               POSTAction:nil]
             withName:@"displayed"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:nil
                               POSTAction:@selector(findElement:)]
             withName:@"element"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:nil
                               POSTAction:@selector(findElements:)]
             withName:@"elements"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:@selector(isEnabled)
                               POSTAction:nil]
             withName:@"enabled"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:@selector(tagName)
                               POSTAction:nil]
             withName:@"name"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:@selector(isSelected)
                               POSTAction:nil]
             withName:@"selected"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:nil
                               POSTAction:@selector(submit:)]
             withName:@"submit"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:@selector(text)
                               POSTAction:nil]
             withName:@"text"];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:nil
                               POSTAction:@selector(sendKeys:)]
             withName:@"value"];

    [self setResource:[NDAttribute attributeForElement:element_]
             withName:@"attribute"];
  }
  return self;
}

- (void)dealloc {
  [element_ release];
  [super dealloc];
}

// Creates new element directory.
+ (NDElementDirectory *)directoryWithElement:(NDElement *)element
                                elementStore:(NDElementStore *)elementStore {
  return [[[NDElementDirectory alloc] initWithElement:element
                                         elementStore:elementStore]
          autorelease];
}

// Clear the contents of this element if it is an input field. Otherwise, do
// nothing.
- (void)clear:(NSDictionary*)ignored {
  [self verifyElementStillAlive];
  [self verifyElementVisible];
  [self verifyElementEnabled];

  [element_ clear];
}

// Simulate a click on the element.
- (void)click:(NSDictionary*)ignored {
  [self verifyElementStillAlive];
  [self verifyElementVisible];

  if ([element_ isEnabled]) {
    [element_ click];
  }
}

// Finds one element inside this element
- (NSDictionary *)findElement:(NSDictionary*)query {
  return [elementStore_ findElement:query root:element_];
}

// Finds elements inside this element
- (NSArray *)findElements:(NSDictionary*)query {
  return [elementStore_ findElements:query root:element_];
}

// Is the element displayed on the screen?
- (NSNumber *)isDisplayed {
  [self verifyElementStillAlive];
  return [NSNumber numberWithBool:[element_ isDisplayed]];
}

// Is the element enabled?
- (NSNumber *)isEnabled {
  [self verifyElementStillAlive];
  return [NSNumber numberWithBool:[element_ isEnabled]];
}

// Is the element selected?
- (NSNumber *)isSelected {
  [self verifyElementStillAlive];
  return [NSNumber numberWithBool:[element_ isSelected]];
}

// Use this method to simulate typing into an element, which may set its value.
- (void)sendKeys:(NSDictionary *)dict {
  [self verifyElementStillAlive];
  [self verifyElementVisible];

  if ([element_ isEnabled]) {
    [element_ sendKeys:[dict objectForKey:@"value"]];
  }
}

// Type return key into the element. If the element is Web element, this method
// will submit this form, or the form containing this element.
- (void)submit:(NSDictionary *)ignored {
  [self verifyElementStillAlive];
  [self verifyElementVisible];

  if ([element_ isEnabled]) {
    [element_ submit];
  }
}

// Get the tag name of this element, not the value of the name attribute:
// will return "input" for the element <input name="foo">. For native elements,
// returns the class name.
- (NSString *)tagName {
  [self verifyElementStillAlive];
  return [element_ tagName];
}

// The text contained in the element.
- (NSString *)text {
  [self verifyElementStillAlive];
  return [element_ text];
}

// Throws an WebDriver exception is the element is not alive.
- (void)verifyElementStillAlive {
  if (![element_ isAlive]) {
    @throw([NSException
            webDriverExceptionWithMessage:@"The element is not alive."
                            andStatusCode:EOBSOLETEELEMENT]);
  }
}

// Throws an WebDriver exception is the element is not selectable.
// TODO(tkaizu): The constant name EELEMENTNOTSELECTED seems typo. The value is
//               15, and it is defined as ElementIsNotSelectable in the Wiki
//               page.
- (void)verifyElementSelectable {
  if (![element_ isSelectable]) {
    @throw([NSException
            webDriverExceptionWithMessage:@"The element is not selectable."
                            andStatusCode:EELEMENTNOTSELECTED]);
  }
}

// Throws an WebDriver exception is the element is not visible.
- (void)verifyElementVisible {
  if (![element_ isDisplayed]) {
    @throw([NSException
            webDriverExceptionWithMessage:@"The element is not visible."
                            andStatusCode:EELEMENTNOTDISPLAYED]);
  }
}

// Throws an WebDriver exception is the element is not enabled.
- (void)verifyElementEnabled {
  if (![self isEnabled]) {
    @throw([NSException
            webDriverExceptionWithMessage:@"The element is not enabled."
                            andStatusCode:EELEMENTNOTENABLED]);
  }
}

@end

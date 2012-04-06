//
//  NDElementStore.m
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

#import "NDElementStore.h"

#import "errorcodes.h"
#import "GTMNSString+URLArguments.h"
#import "NDElementDirectory.h"
#import "NDNativeElement.h"
#import "NDSession.h"
#import "NDWebElement.h"
#import "NSException+WebDriver.h"
#import "WebDriverResource.h"

static NSString *kElementIdKey = @"ELEMENT";
static NSString *kFindElementUsingKey = @"using";
static NSString *kFindElementValueKey = @"value";
static NSTimeInterval kSleepTimeInterval = 0.25;

@class NDElement;

@interface NDElementStore ()

- (id)initWithSession:(NDSession *)session;

- (NSString *)elementIdForView:(UIView *)view;

- (NSDictionary *)registerElement:(NDElement *)element;

- (NSDictionary *)elements;

- (NSArray *)findElementsBy:(NSString *)by
                      value:(NSString *)value
                       root:(NDElement *)root
                   maxCount:(NSUInteger)maxCount;

- (NSArray *)findElements:(NSDictionary *)query
                     root:(NDElement *)root
                 maxCount:(NSUInteger)maxCount;

- (NSDictionary *)findElement:(NSDictionary *)query;

- (NSArray *)findElements:(NSDictionary *)query;

- (NDNativeElement *)defaultNativeRoot;

- (void)sleep;

@end

@implementation NDElementStore

@synthesize session = session_;

// Initializes an element store. Installs itself as the /element and /elements
// virtual directory handler for the given |session|.
- (id)initWithSession:(NDSession *)session {
  if ((self = [super init])) {
    session_ = session;
    elements_ = [[NSMutableDictionary dictionary] retain];

    [session setResource:self withName:@"element"];
    [self setIndex:[WebDriverResource
                    resourceWithTarget:self
                             GETAction:nil
                            POSTAction:@selector(findElement:)]];

    [session setResource:[WebDriverResource
                          resourceWithTarget:self
                                   GETAction:nil
                                  POSTAction:@selector(findElements:)]
                withName:@"elements"];
  }
  return self;
}

- (void)dealloc {
  [elements_ release];
  [super dealloc];
}

+ (NDElementStore *)elementStoreWithSession:(NDSession *)session {
  return [[[NDElementStore alloc] initWithSession:session] autorelease];
}

- (NSDictionary *)findElement:(NSDictionary *)query
                         root:(NDElement *)root {
  NSArray *found = [self findElements:query root:root maxCount:1U];
  if ([found count] == 0) {
    @throw([NSException
            webDriverExceptionWithMessage:@"Unable to locate element"
                            andStatusCode:ENOSUCHELEMENT]);
  }
  return [found objectAtIndex:0];
}

- (NSArray *)findElements:(NSDictionary *)query
                     root:(NDElement *)root {
  return [self findElements:query root:root maxCount:kFindEverything];
}

// Returns an elementId for specified |UIView| used in WebDriver API. The
// mappings between elementId and view are stored in |elements_| field. If the
// mapping for the object already exists, returns the existing elementId.
// Otherwise, creates new id.
- (NSString *)elementIdForView:(UIView *)view {
  NSArray *keys = [elements_ allKeysForObject:view];
  if ([keys count] > 0) {
    return [keys objectAtIndex:0];
  }
  NSString *elementId = [NSString stringWithFormat:@"%d", nextId_];
  [elements_ setObject:view forKey:elementId];
  nextId_++;
  return elementId;
}

// Registers the element in /element/X URL. If already there is a directory for
// the element, just returns the existing id. Otherwise, creates new element
// directory. Returns a elementId in WebDriver API format, in other words,
// returns a dictionary whose value for key "ELEMENT" is elementId.
- (NSDictionary *)registerElement:(NDElement *)element {
  NSString *elementId = nil;

  if ([element isKindOfClass:[NDNativeElement class]]) {
    NDNativeElement *nativeElement = (NDNativeElement *)element;
    elementId = [self elementIdForView:[nativeElement view]];
  } else if ([element isKindOfClass:[NDWebElement class]]) {
    NDWebElement *webElement = (NDWebElement *)element;
    NSString *webViewId = [self elementIdForView:[webElement webView]];
    NSString *webDriverId = [webElement webDriverId];
    elementId = [NSString stringWithFormat:@"%@%@", webViewId, webDriverId];
  } else {
    @throw [NSException webDriverExceptionWithMessage:@"Not yet implemented."
                                        andStatusCode:EUNHANDLEDERROR];
  }
  // |contents| is a mapping from URL fragment to |HTTPVirtualDirectory|,
  // defined in HTTPVirtualDirectory.h. We need to URL encode the URL fragment.
  NSString *escapedElementId = [elementId gtm_stringByEscapingForURLArgument];
  if (![contents objectForKey:escapedElementId]) {
    NDElementDirectory *resource =
        [NDElementDirectory directoryWithElement:element
                                    elementStore:[session_ elementStore]];
    [contents setObject:resource forKey:escapedElementId];
  }
  return [NSDictionary dictionaryWithObject:elementId forKey:kElementIdKey];
}

// This method is for testing purposes. Returns elements_ field.
- (NSDictionary *)elements {
  return elements_;
}

// This method is for testing purposes. Only calls a method of |NDElement|.
// Stubs can override this.
- (NSArray *)findElementsBy:(NSString *)by
                      value:(NSString *)value
                       root:(NDElement *)root
                   maxCount:(NSUInteger)maxCount {
  return [root findElementsBy:by value:value maxCount:maxCount];
}

// Finds elements for |query| by using NDElementFinder. Returns an array of
// |NSDictionary|. Each dictionary represents an elementId in WebDriver API
// format. If |root| is nil, finds descendants of the default root.
- (NSArray *)findElements:(NSDictionary *)query
                     root:(NDElement *)root
                 maxCount:(NSUInteger)maxCount {
  NSString *using = [query valueForKey:kFindElementUsingKey];
  NSString *value = [query valueForKey:kFindElementValueKey];
  NSDate *startTime = [NSDate dateWithTimeIntervalSinceNow:0];
  NSTimeInterval implicitWait = [self.session implicitWait];

  if (root == nil) {
    root = [self defaultNativeRoot];
  }

  // Wait until any element is found or elapsed time exceeds the specified
  // interval.
  NSArray *elements = nil;
  while (true) {
    elements = [self findElementsBy:using
                              value:value
                               root:root
                           maxCount:maxCount];
    if ([elements count] > 0) {
      break;
    }
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval elapsedTime = [now timeIntervalSinceDate:startTime];
    if (elapsedTime > implicitWait) {
      break;
    }
    [self sleep];
  }

  // Register elements and return results in WebDriver API format.
  NSMutableArray *results = [NSMutableArray array];
  for (NDElement *element in elements) {
    [results addObject:[self registerElement:element]];
  }
  return results;
}

// Responds to /element query.
- (NSDictionary *)findElement:(NSDictionary *)query {
  return [self findElement:query root:nil];
}

// Responds to /elements query.
- (NSArray *)findElements:(NSDictionary *)query {
  return [self findElements:query root:nil];
}

// Returns default native root element for findElements.
- (NDNativeElement *)defaultNativeRoot {
  UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
  return [NDNativeElement elementWithView:keyWindow];
}

// Sleeps for a while.
- (void)sleep {
  [NSThread sleepForTimeInterval:kSleepTimeInterval];
}

@end

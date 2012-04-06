//
//  NDElementStoreTest.m
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

#import "NDElementStoreTest.h"

#import "NDNativeElement.h"
#import "NDSession.h"
#import "NDSessionRoot.h"
#import "NDWebElement.h"

// A dummy interface to access the private method.
@interface NDElementStore (PrivateMethods)

- (id)initWithSession:(NDSession *)session;
- (NSDictionary *)elements;
- (void)sleep;

@end

@implementation NDElementStoreStub

@synthesize by = by_;
@synthesize value = value_;
@synthesize root = root_;
@synthesize maxCount = maxCount_;
@synthesize results = results_;
@synthesize defaultNativeElement = defaultNativeElement_;

- (id)initWithSession:(NDSession *)session {
  if (([super initWithSession:session])) {
    defaultNativeElement_ = [[NDNativeElement elementWithView:nil] retain];
    results_ = [[NSMutableArray array] retain];
  }
  return self;
}

- (id)init {
  return [self initWithSession:nil];
}

- (void)dealloc {
  [by_ release];
  [value_ release];
  [root_ release];
  [results_ release];
  [defaultNativeElement_ release];
  [super dealloc];
}

- (NSArray *)findElementsBy:(NSString *)by
                      value:(NSString *)value
                       root:(NDElement *)root
                   maxCount:(NSUInteger)maxCount {
  [self setBy:by];
  [self setValue:value];
  [self setRoot:root];
  [self setMaxCount:maxCount];
  return [self.results objectAtIndex:0];
}

- (NDNativeElement *)defaultNativeRoot {
  return defaultNativeElement_;
}

- (void)addResult:(NSArray *)result {
  [self.results addObject:result];
}

- (NSDictionary *)contents {
  return contents;
}

- (void)sleep {
  // Remove first result. Next one will be used in next findElements.
  [self.results removeObjectAtIndex:0];
}

@end

@implementation NDElementStoreTest

- (void)testfindElement {
  NDElementStoreStub *store = [[[NDElementStoreStub alloc] init] autorelease];

  UIView *view1 = [[[UIView alloc] init] autorelease];
  NDNativeElement *element1 = [NDNativeElement elementWithView:view1];
  NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                         kByText, @"using", @"foo", @"value", nil];
  [store addResult:[NSArray arrayWithObject:element1]];
  NSDictionary *result1 = [store findElement:query root:nil];

  STAssertEqualStrings(@"text", [store by], @"By should be passed.");
  STAssertEqualStrings(@"foo", [store value], @"Value should be passed.");
  STAssertEquals([store defaultNativeElement], [store root],
                 @"Default Element should be set.");
  STAssertEquals(1U, [store maxCount], @"maxCount should be 1.");
  STAssertEqualStrings(@"0", [result1 objectForKey:@"ELEMENT"],
                       @"Should assign new element id.");
  STAssertEquals(1U, [[store elements] count], @"Should have only 1 entry.");
}

- (void)testFindPreregisteredElement {
  NDElementStoreStub *store = [[[NDElementStoreStub alloc] init] autorelease];

  UIView *view1 = [[[UIView alloc] init] autorelease];
  UIView *view2 = [[[UIView alloc] init] autorelease];
  NDNativeElement *element1 = [NDNativeElement elementWithView:view1];
  NDNativeElement *element2 = [NDNativeElement elementWithView:view2];

  // Find element first.
  NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                         kByText, @"using", @"foo", @"value", nil];
  [store addResult:[NSArray arrayWithObject:element1]];
  NSDictionary *result1 = [store findElement:query root:nil];
  STAssertEqualStrings(@"0", [result1 objectForKey:@"ELEMENT"],
                       @"Should assign new element id.");
  STAssertEquals(1U, [[store elements] count], @"Should have only 1 entry.");

  // In second search, NDElementStore should return preregistered element.
  query = [NSDictionary dictionaryWithObjectsAndKeys:
           kByClassName, @"using", @"bar", @"value", nil];
  [[store results] removeAllObjects];
  [store addResult:[NSArray arrayWithObjects:element1, element2, nil]];
  NSArray *result2 = [store findElements:query root:element1];

  STAssertEqualStrings(kByClassName, [store by], @"By should be passed.");
  STAssertEqualStrings(@"bar", [store value], @"Value should be passed.");
  STAssertEquals(element1, [store root], @"root element should be passed.");
  STAssertEquals(0U, [store maxCount], @"maxCount should be 0.");
  STAssertEquals(2U, [result2 count], @"Should return 2 elements.");
  STAssertEqualStrings(@"0",
                       [[result2 objectAtIndex:0] objectForKey:@"ELEMENT"],
                       @"Should reuse existing element id.");
  STAssertEqualStrings(@"1",
                       [[result2 objectAtIndex:1] objectForKey:@"ELEMENT"],
                       @"Should assign new element id.");
  STAssertEquals(2U, [[store elements] count], @"Should have only 2 entries.");
}

- (void)testRegisterWebElement {
  // UIWebView crashes when calling |init| in unit test environment. We just
  // need any UIWebView pointer, so we call only |alloc|.
  UIWebView *webView = [[UIWebView alloc] autorelease];
  NDWebElement *element = [NDWebElement elementWithWebView:webView
                                               webDriverId:@":1234"];
  NDElementStoreStub *store = [[[NDElementStoreStub alloc] init] autorelease];
  [store addResult:[NSArray arrayWithObject:element]];

  NSDictionary *result = [store findElement:nil root:nil];
  STAssertEqualStrings(@"0:1234", [result objectForKey:@"ELEMENT"],
                       @"Element id should be generated with WebDriver id.");
  STAssertNotNil([[store contents] objectForKey:@"0%3A1234"],
                 @"Encoded URL should be registered.");
}

- (void)testWaitUntilFindElements {
  NDSession *session = [NDSession sessionWithSessionRoot:nil sessionId:0];
  [session setImplicitWait:1.0];
  NDElementStoreStub *store =
      [[[NDElementStoreStub alloc] initWithSession:session] autorelease];
  UIView *view1 = [[[UIView alloc] init] autorelease];
  NDNativeElement *element1 = [NDNativeElement elementWithView:view1];
  [store addResult:[NSArray array]];
  [store addResult:[NSArray array]];
  [store addResult:[NSArray arrayWithObject:element1]];
  NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                         kByText, @"using", @"foo", @"value", nil];

  NSArray *result = [store findElements:query root:nil];
  STAssertEquals(1U, [[store results] count], @"Should wait until found.");
  STAssertEquals(1U, [result count], @"Should return found element.");
}

- (void)testFindElementTimeout {
  NDSession *session = [NDSession sessionWithSessionRoot:nil sessionId:0];
  [session setImplicitWait:0.0];
  NDElementStoreStub *store =
      [[[NDElementStoreStub alloc] initWithSession:session] autorelease];
  NDNativeElement *element1 = [NDNativeElement elementWithView:nil];
  [store addResult:[NSArray array]];
  [store addResult:[NSArray arrayWithObject:element1]];
  NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                         kByText, @"using", @"foo", @"value", nil];
  @try {
    [store findElement:query root:nil];
    STFail(@"Should throw exception");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings([exception name], @"kWebDriverException",
                         @"Should throw WebDriver Exception.");
  }
}

- (void)testFindElementsTimeout {
  NDSession *session = [NDSession sessionWithSessionRoot:nil sessionId:0];
  [session setImplicitWait:0.0];
  NDElementStoreStub *store =
      [[[NDElementStoreStub alloc] initWithSession:session] autorelease];
  NDNativeElement *element1 = [NDNativeElement elementWithView:nil];
  [store addResult:[NSArray array]];
  [store addResult:[NSArray arrayWithObject:element1]];
  NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                         kByText, @"using", @"foo", @"value", nil];
  NSArray *result = [store findElements:query root:nil];
  STAssertEquals(0U, [result count], @"Should not return elements.");
}

@end

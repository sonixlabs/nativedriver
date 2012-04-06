//
//  NDJavaScriptRunnerTest.m
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

#import "NDJavaScriptRunnerTest.h"

#import "atoms.h"
#import "NDJavaScriptRunner.h"
#import "OCMock/OCMock.h"

@implementation NDJavaScriptRunnerTest

- (void)testExecuteJsFunction {
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  NSString *executeScript = [NSString stringWithFormat:
      @"(%@)(function(){return 42;},[],true)",
      [NSString stringWithUTF8String:webdriver::atoms::EXECUTE_SCRIPT]];
  [[[webView stub] andReturn:@"{\"status\":0,\"value\":\"42\"}"]
   stringByEvaluatingJavaScriptFromString:executeScript];

  id result = [NDJavaScriptRunner executeJsFunction:@"function(){return 42;}"
                                           withArgs:[NSArray array]
                                            webView:webView];

  STAssertEqualStrings(result, @"42", @"Should return value property.");

  [webView verify];
}

- (void)testExecuteJsFunctionWithError {
  id webView = [OCMockObject mockForClass:[UIWebView class]];
  NSString *executeScript = [NSString stringWithFormat:@"(%@)(f,[],true)",
      [NSString stringWithUTF8String:webdriver::atoms::EXECUTE_SCRIPT]];
  [[[webView stub]
      andReturn:@"{\"status\":1,\"value\":{\"message\":\"message1\"}}"]
      stringByEvaluatingJavaScriptFromString:executeScript];

  @try {
    [NDJavaScriptRunner executeJsFunction:@"f"
                                 withArgs:[NSArray array]
                                  webView:webView];
    STFail(@"Should throw exception.");
  }
  @catch (NSException *exception) {
    STAssertEqualStrings([exception name], @"kWebDriverException",
                         @"Should throw WebDriver Exception.");
    STAssertEqualStrings([exception reason], @"message1",
                         @"Should return message property.");
  }

  [webView verify];
}
@end

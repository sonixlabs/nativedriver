//
//  NDNativeSwitchElementTest.m
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

#import "NDNativeSwitchElementTest.h"

#import "NDNativeSwitchElement.h"
#import "OCMock/OCMock.h"

@implementation NDNativeSwitchElementTest

// If current state is OFF, |setOn:YES| should be called.
- (void)testClickOffToOn {
  id switchView = [OCMockObject mockForClass:[UISwitch class]];
  NDNativeSwitchElement *element =
      [[[NDNativeSwitchElement alloc] initWithView:switchView] autorelease];

  [[[switchView stub] andReturnValue:[NSNumber numberWithBool:NO]] isOn];
  [[switchView expect] setOn:YES animated:YES];
  [[switchView expect] sendActionsForControlEvents:UIControlEventValueChanged];

  [element click];

  [switchView verify];
}

// If current state is ON, |setOn:NO| should be called.
- (void)testClickOnToOff {
  id switchView = [OCMockObject mockForClass:[UISwitch class]];
  NDNativeSwitchElement *element =
      [[[NDNativeSwitchElement alloc] initWithView:switchView] autorelease];

  [[[switchView stub] andReturnValue:[NSNumber numberWithBool:YES]] isOn];
  [[switchView expect] setOn:NO animated:YES];
  [[switchView expect] sendActionsForControlEvents:UIControlEventValueChanged];

  [element click];

  [switchView verify];
}

@end

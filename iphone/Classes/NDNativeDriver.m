//
//  NativeDriver.m
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

#import "NDNativeDriver.h"

#import "HTTPServerController.h"
#import "WebDriverPreferences.h"

@implementation NDNativeDriver

// Starts NativeDriver. Since we have no preferences page with NativeDriver,
// always uses port 3001.
+ (void)start {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setInteger:3001 forKey:@"preference_server_mode_port_number"];
  [HTTPServerController sharedInstance];
}

@end

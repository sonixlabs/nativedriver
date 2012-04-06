/*
Copyright 2011 NativeDriver committers
Copyright 2011 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package com.google.android.testing.nativedriver.common;

import org.openqa.selenium.remote.DriverCommand;

/**
 * Extends {@code DriverCommand} interface to add Android-specific commands.
 * 
 * @author Steve Salevan
 */
public interface AndroidNativeDriverCommand extends DriverCommand {
  String SEND_KEYS_TO_SESSION = "sendKeysToElement";
  String SEND_MODIFIER_KEY_TO_SESSION = "sendModifierKeyToActiveElement";
}

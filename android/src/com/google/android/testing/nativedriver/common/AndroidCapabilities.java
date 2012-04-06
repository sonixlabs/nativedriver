/*
Copyright 2010 NativeDriver committers
Copyright 2010 Google Inc.

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

import org.openqa.selenium.Platform;
import org.openqa.selenium.remote.DesiredCapabilities;

/**
 * Utility method for creating a {@link DesiredCapabilities} object which
 * matches the Android NativeDriver (AND).
 *
 * @author Matt DeVore
 */
public final class AndroidCapabilities {
  private AndroidCapabilities() {}

  /**
   * Returns a {@code DesiredCapabilities} object that matches the AND. Users
   * of AND generally do not need to call this method directly.
   */
  public static DesiredCapabilities get() {
    return new DesiredCapabilities("android native", "2.2", Platform.ANDROID);
  }
}

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

package com.google.android.testing.nativedriver.client;

import org.openqa.selenium.WebDriverException;

/**
 * An exception that occurred when communicating over the Android Debug Bridge.
 *
 * @author Matt DeVore
 */
public class AdbException extends WebDriverException {
  public AdbException() {
    // nothing to do
  }

  public AdbException(String message) {
    super(message);
  }

  public AdbException(Throwable cause) {
    super(cause);
  }

  public AdbException(String message, Throwable cause) {
    super(message, cause);
  }
}

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
package com.google.iphone.testing.nativedriver.client;

/**
 * Represents element types on iOS native applications. These constants free
 * you from typing the class name and make typos less likely to cause a
 * problem when you call findElement(By.className()).
 *
 * @see org.openqa.selenium.internal.FindsByClassName
 * @author Tomohiro Kaizu
 */
public interface ClassNames {
  /**
   * Normal buttons.
   */
  String BUTTON = "UIButton";

  /**
   * Label control.
   */
  String LABEL = "UILabel";

  /**
   * Switch control.
   */
  String SWITCH = "UISwitch";

  /**
   * Text fields with 1 line.
   */
  String TEXT_FIELD = "UITextField";

  /**
   * Text fields with multiple lines.
   */
  String TEXT_VIEW = "UITextView";

  /**
   * Switch control.
   */
  String WEB_VIEW = "UIWebView";
}

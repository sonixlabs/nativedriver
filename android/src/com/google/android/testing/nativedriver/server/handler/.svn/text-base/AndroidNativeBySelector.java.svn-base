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

package com.google.android.testing.nativedriver.server.handler;

import com.google.android.testing.nativedriver.common.AndroidNativeBy;
import com.google.android.testing.nativedriver.common.FindsByText;

import org.openqa.selenium.By;
import org.openqa.selenium.remote.server.handler.BySelector;

/**
 * A {@code BySelector} which supports Android Native-specific search strategies
 * in addition to those supplied by WebDriver.
 *
 * @author Matt DeVore
 */
public class AndroidNativeBySelector extends BySelector {
  @Override
  public By pickFrom(String method, String selector) {
    if (FindsByText.USING_TEXT.equals(method)) {
      return AndroidNativeBy.text(selector);
    } else if (FindsByText.USING_PARTIALTEXT.equals(method)) {
      return AndroidNativeBy.partialText(selector);
    } else {
      return super.pickFrom(method, selector);
    }
  }
}

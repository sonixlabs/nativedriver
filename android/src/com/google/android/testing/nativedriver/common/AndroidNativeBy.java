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

import com.google.common.base.Preconditions;
import com.google.common.base.Strings;

import org.openqa.selenium.By;
import org.openqa.selenium.SearchContext;
import org.openqa.selenium.WebElement;

import java.util.List;

/**
 * Supplies finding strategies that are useful in Android Native applications.
 * The strategies are supplied in the same way {@code By} supplies the standard
 * strategies, such as {@link By#id(String)}. The following code uses the
 * "by text" strategy of {@code AndroidNativeBy} to find all elements with the
 * text {@code "OK"}:
 *
 * <pre>WebElement okButton
 * = androidNativeDriver.findElement(AndroidNativeBy.text("OK");</pre>
 *
 * @author Matt DeVore
 */
public abstract class AndroidNativeBy extends By {
  /**
   * Creates an instance of {@code AndroidNativeBy} which matches all elements
   * whose {@code getText} method return the given value.
   */
  public static AndroidNativeBy text(final String text) {
    Preconditions.checkNotNull(text);

    return new AndroidNativeBy() {
      @Override
      public WebElement findElement(SearchContext context) {
        return ((FindsByText) context).findElementByText(text);
      }

      @Override
      public List<WebElement> findElements(SearchContext context) {
        return ((FindsByText) context).findElementsByText(text);
      }

      @Override
      public String toString() {
        return "AndroidNativeBy.text: " + text;
      }
    };
  }

  /**
   * Creates an instance of {@code AndroidNativeBy} which matches all elements
   * whose {@code getText} method returns a string which contains or equals the
   * given string.
   */
  public static AndroidNativeBy partialText(final String text) {
    Preconditions.checkArgument(!Strings.isNullOrEmpty(text),
        "text argument must be a non-empty, non-null String.");

    return new AndroidNativeBy() {
      @Override
      public WebElement findElement(SearchContext context) {
        return ((FindsByText) context).findElementByPartialText(text);
      }

      @Override
      public List<WebElement> findElements(SearchContext context) {
        return ((FindsByText) context).findElementsByPartialText(text);
      }

      @Override
      public String toString() {
        return "AndroidNativeBy.partialText: " + text;
      }
    };
  }
}

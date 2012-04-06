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

import com.google.common.base.Preconditions;
import com.google.common.base.Strings;

import org.openqa.selenium.SearchContext;
import org.openqa.selenium.WebElement;

import java.util.List;

/**
 * Supplies finding strategies that are useful in iOS Native applications.
 * The strategies are supplied in the same way {@code By} supplies the standard
 * strategies, such as {@link org.openqa.selenium.By#id(String)}.
 * 
 * @author Tomohiro Kaizu
 */
public abstract class By extends org.openqa.selenium.By {
  /**
   * @param text the text to search for
   * @return a By which locates elements by the exact text
   */
  public static By text(final String text) {
    Preconditions.checkArgument(!Strings.isNullOrEmpty(text),
        "text argument must be a non-empty, non-null String.");

    return new By() {
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
        return "By.text: " + text;
      }
    };
  }

  /**
   * @param text the partial text to search for
   * @return a By which locates elements that contain the given text
   */
  public static By partialText(final String text) {
    Preconditions.checkArgument(!Strings.isNullOrEmpty(text),
        "text argument must be a non-empty, non-null String.");

    return new By() {
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
        return "By.partialText: " + text;
      }
    };
  }

  /**
   * @param text the placeholder text to search for
   * @return a By which locates elements by the placeholder text.
   */
  public static By placeholder(final String placeholder) {
    Preconditions.checkNotNull(placeholder);

    return new By() {
      @Override
      public List<WebElement> findElements(SearchContext context) {
        return ((FindsByPlaceholder) context)
            .findElementsByPlaceholder(placeholder);
      }

      @Override
      public WebElement findElement(SearchContext context) {
        return ((FindsByPlaceholder) context)
            .findElementByPlaceholder(placeholder);
      }

      @Override
      public String toString() {
        return "By.placeholder: " + placeholder;
      }
    };
  }
}

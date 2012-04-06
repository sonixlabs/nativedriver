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

package com.google.android.testing.nativedriver;

import com.google.android.testing.nativedriver.client.AndroidNativeDriver;
import com.google.android.testing.nativedriver.client.AndroidNativeDriverBuilder;
import com.google.android.testing.nativedriver.common.AndroidNativeBy;

import junit.framework.TestCase;

/**
 * An integration test which verifies the click and requestRectangleOnScreen
 * functionalities in
 * {@link com.google.android.testing.nativedriver.server.ViewElement}.
 *
 * @author Dezheng Xu
 */
public class ListViewTest extends TestCase {
  private String[] states = {
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
    "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
  };

  private AndroidNativeDriver driver;

  @Override
  protected void setUp() {
    driver = getDriver();
  }

  @Override
  protected void tearDown() {
    driver.quit();
  }

  protected AndroidNativeDriver getDriver() {
    return new AndroidNativeDriverBuilder()
        .withDefaultServer()
        .build();
  }

  private void startListViewActivity() {
    driver.startActivity("com.google.android.testing.nativedriver."
        + "simplelayouts.ListViewActivity");
  }

  // At first, not all elements are visible, but gradual scrolling works
  // automatically because the click is performed in order vertically.
  public void testClickListItems_scrollsGradually() {
    startListViewActivity();
    for (String state : states) {
      driver.findElement(AndroidNativeBy.text(state)).click();
    }
  }
}

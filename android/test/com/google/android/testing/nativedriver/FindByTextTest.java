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
import com.google.android.testing.nativedriver.client.AndroidNativeElement;
import com.google.android.testing.nativedriver.common.AndroidKeys;
import com.google.android.testing.nativedriver.common.AndroidNativeBy;
import com.google.common.collect.ImmutableList;

import junit.framework.TestCase;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;

import java.util.List;

/**
 * An integration test which exercises the
 * {@link com.google.android.testing.nativedriver.common.FindsByText}
 * implementation on the elements and driver classes.
 *
 * @author Matt DeVore
 */
public class FindByTextTest extends TestCase {
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

  private void startSpinnersActivity() {
    driver.startActivity("com.google.android.testing.nativedriver." +
        "simplelayouts.SpinnersActivity");
  }

  public void testFindByText_noResults() {
    startSpinnersActivity();
    driver.findElement(By.id("planet_spinner")).click();
    driver.findElement(AndroidNativeBy.text("Earth"));

    try {
      // Search for something that should not appear. Pluto is not a planet.
      driver.findElement(AndroidNativeBy.text("Pluto"));
      fail("Should have thrown a NoSuchElementException.");
    } catch (NoSuchElementException exception) {
      // Expected exception.
    }
  }

  public void testFindByText_resultFromSpinnerPopup() {
    startSpinnersActivity();
    AndroidNativeElement starsSpinner
        = driver.findElement(By.id("star_spinner"));
    starsSpinner.click();
    driver.findElement(AndroidNativeBy.text("Wolf 359")).click();

    assertEquals(
        "'Wolf 359' should appear in child TextView of the spinner control.",
        1, starsSpinner.findElements(AndroidNativeBy.text("Wolf 359")).size());
  }

  public void testFindByText_elementInitiallyInvisible() {
    startSpinnersActivity();
    driver.findElement(By.id("planet_spinner")).click();
    driver.findElement(AndroidNativeBy.text("Choose a planet"));

    assertEquals("Element with text 'Neptune' should be invisible at first.",
        ImmutableList.of(),
        driver.findElements(AndroidNativeBy.text("Neptune")));

    String toSend = "";
    for (int i = 0; i < 8; i++) {
      toSend += AndroidKeys.DPAD_DOWN;
    }
    driver.findElement(AndroidNativeBy.text("Choose a planet"))
        .sendKeys(toSend);

    driver.findElement(AndroidNativeBy.text("Neptune"));
  }

  public void testFindByPartialText_multipleResultsFromSpinnerPopup() {
    startSpinnersActivity();
    driver.findElement(By.id("planet_spinner")).click();

    // Ensure the new UI is focused by performing a UI operation
    driver.findElement(AndroidNativeBy.text("Choose a planet"))
        .sendKeys(AndroidKeys.DPAD_DOWN, AndroidKeys.DPAD_UP);

    List<AndroidNativeElement> elementsWithArInText
        = driver.findAndroidNativeElements(AndroidNativeBy.partialText("ar"));

    // Note that the word "Stars" in the main activity window also has 'ar' in
    // its name, but this window is out of focus so it should be omitted from
    // the search results.
    assertEquals(
        "Should have found two planets with 'ar' in name: Earth and Mars.",
        2, elementsWithArInText.size());
  }
}

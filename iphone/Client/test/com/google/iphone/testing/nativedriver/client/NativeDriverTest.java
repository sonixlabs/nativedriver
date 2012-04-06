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

import junit.framework.TestCase;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.util.concurrent.TimeUnit;

/**
 * Sample test for iOS NativeDriver.
 * 
 * @author Tomohiro Kaizu
 */
public class NativeDriverTest extends TestCase{
  public void testNativeDriver() throws Exception {
    WebDriver driver = new IosNativeDriver();
    driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);

    // Type user name
    WebElement userName = driver.findElement(By.placeholder("User Name"));
    userName.clear();
    userName.sendKeys("NativeDriver");
    // Type password
    WebElement password = driver.findElement(By.placeholder("Password"));
    password.clear();
    password.sendKeys("abcdefgh");
    // Tap "Sign in" button
    driver.findElement(By.text("Sign in")).click();

    // Verify correct title is displayed
    String text = driver.getTitle();
    assertEquals("NativeDriver", text);

    // Type text in WebView
    WebElement element = driver.findElement(By.name("q"));
    element.sendKeys("NativeDriver");
    element.submit();

    // Click link
    driver.findElement(By.partialLinkText("GUI automation")).click();
    // Verify the page
    assertEquals("nativedriver", driver.findElement(By.id("pname")).getText());
  }
}

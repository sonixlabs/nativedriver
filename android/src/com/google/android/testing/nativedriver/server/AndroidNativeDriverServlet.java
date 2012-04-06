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

package com.google.android.testing.nativedriver.server;

import com.google.android.testing.nativedriver.common.AndroidCapabilities;
import com.google.android.testing.nativedriver.server.handler.AndroidNativeFindChildElement;
import com.google.android.testing.nativedriver.server.handler.AndroidNativeFindChildElements;
import com.google.android.testing.nativedriver.server.handler.AndroidNativeFindElement;
import com.google.android.testing.nativedriver.server.handler.AndroidNativeFindElements;
import com.google.android.testing.nativedriver.server.handler.AndroidNativeSendKeys;
import com.google.android.testing.nativedriver.server.handler.Click;
import com.google.android.testing.nativedriver.server.handler.DoubleTap;
import com.google.android.testing.nativedriver.server.handler.TouchDown;
import com.google.android.testing.nativedriver.server.handler.TouchMove;
import com.google.android.testing.nativedriver.server.handler.TouchUp;

import org.openqa.selenium.remote.server.DefaultDriverSessions;
import org.openqa.selenium.remote.server.DriverServlet;
import org.openqa.selenium.remote.server.renderer.EmptyResult;
import org.openqa.selenium.remote.server.renderer.JsonResult;
import org.openqa.selenium.remote.server.rest.ResultType;

import javax.servlet.ServletException;

/**
 * Extension of the WebDriver default DriverServlet class which registers and
 * configures the Android NativeDriver (AND) for use with the WebDriver
 * server framework.
 *
 * @author Tomohiro Kaizu
 * @author Dezheng Xu
 * @author Matt DeVore
 */
public class AndroidNativeDriverServlet extends DriverServlet {
  protected static final String SESSION_PATH = "/session/:sessionId/";

  /**
   * Registers the AND WebDriver implementation with the Jetty server so AND
   * will start when the corresponding Capabilities are requested. Then it calls
   * the base class' implementation.
   */
  @Override
  public void init() throws ServletException {
    DefaultDriverSessions driverSessions = new DefaultDriverSessions();
    driverSessions.registerDriver(AndroidCapabilities.get(),
        AndroidNativeDriver.class);
    getServletContext().setAttribute(SESSIONS_KEY, driverSessions);
    super.init();

    try {
      addNewPostMapping(
          SESSION_PATH + "element", AndroidNativeFindElement.class)
          .on(ResultType.SUCCESS, newJsonResult());
      addNewPostMapping(
          SESSION_PATH + "elements", AndroidNativeFindElements.class)
          .on(ResultType.SUCCESS, newJsonResult());
      addNewPostMapping(SESSION_PATH + "element/:id/element",
          AndroidNativeFindChildElement.class)
          .on(ResultType.SUCCESS, newJsonResult());
      addNewPostMapping(SESSION_PATH + "element/:id/elements",
          AndroidNativeFindChildElements.class)
          .on(ResultType.SUCCESS, newJsonResult());

      addNewPostMapping(SESSION_PATH + "element/:id/value",
          AndroidNativeSendKeys.class)
          .on(ResultType.SUCCESS, newEmptyResult());

      addNewPostMapping(SESSION_PATH + "click", Click.class)
          .on(ResultType.SUCCESS, newEmptyResult());
      addNewPostMapping(SESSION_PATH + "doubleclick", DoubleTap.class)
          .on(ResultType.SUCCESS, newEmptyResult());
      addNewPostMapping(SESSION_PATH + "buttondown", TouchDown.class)
          .on(ResultType.SUCCESS, newEmptyResult());
      addNewPostMapping(SESSION_PATH + "moveto", TouchMove.class)
          .on(ResultType.SUCCESS, newEmptyResult());
      addNewPostMapping(SESSION_PATH + "buttonup", TouchUp.class)
          .on(ResultType.SUCCESS, newEmptyResult());
    } catch (Exception exception) {
      throw new ServletException(exception);
    }
  }

  protected JsonResult newJsonResult() {
    return new JsonResult(":response");
  }

  protected EmptyResult newEmptyResult() {
    return new EmptyResult();
  }
}

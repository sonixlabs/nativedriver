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

import com.google.android.testing.nativedriver.common.HasTouchScreen;
import com.google.android.testing.nativedriver.common.Touch;

import org.openqa.selenium.remote.server.DriverSessions;
import org.openqa.selenium.remote.server.JsonParametersAware;
import org.openqa.selenium.remote.server.handler.WebDriverHandler;
import org.openqa.selenium.remote.server.rest.ResultType;

import java.util.Map;

/**
 * Handler of {@code /session/:sessionId/click} for interaction of touch screen
 *
 * @author Dezheng Xu
 */
public class Click extends WebDriverHandler implements JsonParametersAware {
  volatile boolean isLongClick;

  public Click(DriverSessions sessions) {
    super(sessions);
  }

  @Override
  public ResultType call() throws Exception {
    Touch touch = ((HasTouchScreen) getDriver()).getTouch();
    if (isLongClick) {
      touch.longClick(null);
    } else {
      touch.tap(null);
    }
    return ResultType.SUCCESS;
  }

  @Override
  public String toString() {
    return String.format("[tap or longclick on last active coordinates]");
  }

  @Override
  public void setJsonParameters(Map<String, Object> allParameters)
      throws Exception {
    if (allParameters.containsKey("button")) {
      int button = ((Long) allParameters.get("button")).intValue();
      isLongClick = (button == 2);
      // For the mouse case, 0 = leftclick, 2 = rightclick/contextclick
    }
  }
}

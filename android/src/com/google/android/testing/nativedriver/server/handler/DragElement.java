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

import java.util.Map;

import org.openqa.selenium.internal.HasAndroidNativeCommand;
import org.openqa.selenium.remote.server.JsonParametersAware;
import org.openqa.selenium.remote.server.Session;
import org.openqa.selenium.remote.server.handler.WebElementHandler;
import org.openqa.selenium.remote.server.rest.ResultType;

/**
 * Handler of {@code /session/:sessionId/drag_element} for interaction of touch screen
 * 
 * @author Kazuhiro Yamada
 */

public class DragElement extends WebElementHandler implements JsonParametersAware{
  private volatile int x;
  private volatile int y;
  
  public DragElement(Session session) {
    super(session);
  }

  @Override
  public void setJsonParameters(Map<String, Object> allParameters)
      throws Exception {
    x = Integer.parseInt(allParameters.get("x").toString());
    y = Integer.parseInt(allParameters.get("y").toString());
  }
  
  public ResultType call() throws Exception {
    ((HasAndroidNativeCommand)getElement()).drag(x, y);
    return ResultType.SUCCESS;
  }

  @Override
  public String toString() {
    return String.format("[drag: %s x:%s y:%s]", getElementAsString(), x, y);
  }
}

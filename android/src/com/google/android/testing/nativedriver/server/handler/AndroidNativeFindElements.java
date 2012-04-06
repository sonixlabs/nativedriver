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

import com.google.common.base.Function;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Iterables;
import com.google.common.collect.Sets;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.Response;
import org.openqa.selenium.remote.server.DriverSessions;
import org.openqa.selenium.remote.server.JsonParametersAware;
import org.openqa.selenium.remote.server.handler.WebDriverHandler;
import org.openqa.selenium.remote.server.rest.ResultType;

import java.util.List;
import java.util.Map;
import java.util.Set;

// TODO(matvore): Rewrite this class to extend the corresponding handler in
// WebDriver, and simply override the newBySelector() method and delete all the
// other code. First we have to wait for the handler in WebDriver to support
// overriding that.

/**
 * Handler for {@link org.openqa.selenium.WebDriver#findElements(By)}. Identical
 * to the default WebDriver handler, but uses a different {@code BySelector}
 * implementation.
 *
 * @author Matt DeVore
 */
public class AndroidNativeFindElements
    extends WebDriverHandler implements JsonParametersAware {
  private volatile By by;
  private volatile Response response;

  public AndroidNativeFindElements(DriverSessions sessions) {
    super(sessions);
  }

  @Override
  public void setJsonParameters(Map<String, Object> allParameters)
      throws Exception {
    String method = (String) allParameters.get("using");
    String selector = (String) allParameters.get("value");

    by = new AndroidNativeBySelector().pickFrom(method, selector);
  }

  @Override
  public ResultType call() throws Exception {
    response = newResponse();

    Function<WebElement, Map<String, String>> transform
        = new Function<WebElement, Map<String, String>>() {
      public Map<String, String> apply(WebElement element) {
        return ImmutableMap.of("ELEMENT", getKnownElements().add(element));
      }
    };

    List<WebElement> elements = getDriver().findElements(by);
    Set<Map<String, String>> elementIds
        = Sets.newLinkedHashSet(Iterables.transform(elements, transform));

    response.setValue(elementIds);
    return ResultType.SUCCESS;
  }

  public Response getResponse() {
    return response;
  }

  @Override
  public String toString() {
    return String.format("[find elements: %s]", by);
  }
}

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

import com.google.android.testing.nativedriver.common.HasTouchScreen;
import com.google.android.testing.nativedriver.common.Touch;
import com.google.common.base.Function;
import com.google.common.base.Preconditions;
import com.google.common.base.Strings;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.view.Display;
import android.view.KeyEvent;
import android.view.Surface;

import org.apache.http.NameValuePair;
import org.apache.http.client.utils.URLEncodedUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.Cookie;
import org.openqa.selenium.HasInputDevices;
import org.openqa.selenium.Keyboard;
import org.openqa.selenium.Mouse;
import org.openqa.selenium.Rotatable;
import org.openqa.selenium.ScreenOrientation;
import org.openqa.selenium.SearchContext;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebDriverException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.ActionChainsGenerator;
import org.openqa.selenium.interactions.DefaultActionChainsGenerator;

import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import javax.annotation.Nullable;

/**
 * Represents an Android NativeDriver for driving native Android
 * applications.
 *
 * @author Matt DeVore
 * @author Tomohiro Kaizu
 * @author Dezheng Xu
 */
public class AndroidNativeDriver
    implements WebDriver, Rotatable, HasTouchScreen, HasInputDevices {
  private final ElementContext context;
  private SearchContext rootSearchContext;

  /**
   * Allows configuration of this instance of the driver. Only
   * {@link #timeouts()} is supported. All other methods for manipulating
   * cookies and setting the speed are not supported, and will always throw an
   * {@link UnsupportedOperationException}.
   */
  protected class AndroidNativeOptions implements Options {
    @Override
    public void addCookie(Cookie cookie) {
      throw new UnsupportedOperationException();
    }

    @Override
    public void deleteCookieNamed(String name) {
      throw new UnsupportedOperationException();
    }

    @Override
    public void deleteCookie(Cookie cookie) {
      throw new UnsupportedOperationException();
    }

    @Override
    public void deleteAllCookies() {
      throw new UnsupportedOperationException();
    }

    @Override
    public Set<Cookie> getCookies() {
      throw new UnsupportedOperationException();
    }

    @Override
    public Cookie getCookieNamed(String name) {
      throw new UnsupportedOperationException();
    }

    @Override
    public Timeouts timeouts() {
      return new AndroidNativeTimeouts();
    }

    public ImeHandler ime() {
      throw new UnsupportedOperationException();
    }
  }

  /**
   * Allows configuration of timeout settings of this instance of the driver.
   */
  protected class AndroidNativeTimeouts implements Timeouts {
    @Override
    public Timeouts implicitlyWait(long time, TimeUnit unit) {
      Preconditions.checkArgument(
          time > 0, "time argument should be greater than 0");
      long timeoutInMillis
          = TimeUnit.MILLISECONDS.convert(Math.max(0, time), unit);
      getWait().setTimeoutInMillis(timeoutInMillis);
      return this;
    }

    @Override
    public Timeouts setScriptTimeout(long time, TimeUnit unit) {
      throw new UnsupportedOperationException();
    }
  }

  /**
   * Navigation class. Note: forward and refresh are not supported on an
   * Android device.
   */
  protected class AndroidNativeNavigation implements Navigation {
    @Override
    public void back() {
      context.getInstrumentation().waitForIdleSync();
      try {
        context.getInstrumentation().sendKeyDownUpSync(KeyEvent.KEYCODE_BACK);
      } catch (SecurityException exception) {
        throw new WebDriverException(
            "Pressing the Back button failed. Confirm that the destination "
            + "window is not part of a separate application.", exception);
      }
    }

    @Override
    public void forward() {
      throw new UnsupportedOperationException(
          "The forward operation does not exist in native Android app.");
    }

    @Override
    public void to(String url) {
      get(url);
    }

    @Override
    public void to(URL url) {
      get(url.toString());
    }

    @Override
    public void refresh() {
      throw new UnsupportedOperationException(
          "The refresh operation does not exist in native Android app.");
    }
  }

  public AndroidNativeDriver(ElementContext context) {
    this.context = context;
    // We have to do this in the constructor because the RemoteWebDriver
    // framework expects the browser (test environment) to be in a clean state
    // after driver construction. If this behavior is a problem for your
    // scenario, feel free to make it configurable with an extra argument, but
    // the default constructor (new AndroidNativeDriver()) should execute this
    // line.
    context.getActivities().finishAll();
  }

  public AndroidNativeDriver() {
    this(ElementContext.withDefaults(ServerInstrumentation.getInstance()));
  }

  protected AndroidWait getWait() {
    return context.getElementFinder().getWait();
  }

  protected SearchContext getRootSearchContext() {
    if (rootSearchContext == null) {
      rootSearchContext = context.getElementFinder()
          .getSearchContext(new RootSearchScope(context));
    }

    return rootSearchContext;
  }

  /** Start a new activity either in a new task or the current task. */
  public void startActivity(Class<?> activityClass) {
    Intent intent
        = new Intent(context.getInstrumentation().getContext(), activityClass);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    intent.setAction(Intent.ACTION_MAIN);
    intent.addCategory(Intent.CATEGORY_LAUNCHER);
    context.getInstrumentation().startActivitySync(intent);
  }

  @Override
  public void close() {
    context.getActivities().finishAll();
  }

  @Override
  public WebElement findElement(By by) {
    return getRootSearchContext().findElement(by);
  }

  @Override
  public List<WebElement> findElements(By by) {
    return getRootSearchContext().findElements(by);
  }

  /**
   * Takes a string that looks like a URL and performs an operation based on the
   * contents of the URL. Currently only starting activities is supported.
   * <p>
   * Supported URL type follows:
   * <ul>
   * <li>{@code and-activity://<Activity class name>}<br>
   * start specified activity
   * </ul>
   */
  @Override
  public void get(String url) {
    URI dest;
    try {
      dest = new URI(url);
    } catch (URISyntaxException exception) {
      throw new IllegalArgumentException(exception);
    }

    if (!"and-activity".equals(dest.getScheme())) {
      throw new WebDriverException("Unrecognized scheme in URI: "
          + dest.toString());
    } else if (!Strings.isNullOrEmpty(dest.getPath())) {
      throw new WebDriverException("Unrecognized path in URI: "
          + dest.toString());
    }

    Class<?> clazz;
    try {
      clazz = Class.forName(dest.getAuthority());
    } catch (ClassNotFoundException exception) {
      throw new WebDriverException(
          "The specified Activity class does not exist: " + dest.getAuthority(),
          exception);
    }

    for (NameValuePair nvp : URLEncodedUtils.parse(dest, "utf8")) {
      if ("id".equals(nvp.getName())) {
        // This is to prevent people from recycling the same URL they got from
        // getCurrentUrl() and expecting to return to an arbitrary running
        // activity. It is not supported in the Android user interface so we
        // don't expose this functionality.
        throw new WebDriverException(
            "Moving to the specified activity is not supported.");
      }
    }
    startActivity(clazz);
  }

  /**
   * Returns a string that looks like a URL that describes the current activity.
   * Each running activity is assigned a unique URL, so the URL can be used to
   * detect the starting of new activities or resuming existing activities.
   */
  @Override
  public String getCurrentUrl() {
    Activity activity = context.getActivities().current();
    if (activity == null) {
      return null;
    }
    int id = context.getActivities().idOf(activity);
    if (id == Activities.NO_ID) {
      return null;
    }
    return "and-activity://" + activity.getLocalClassName() + "?id=" + id;
  }

  @Override
  public String getPageSource() {
    throw new UnsupportedOperationException();
  }

  /**
   * Returns title of the activity. Provided to override final method
   * {@link Activity#getTitle()}.
   */
  protected CharSequence getActivityTitle(Activity activity) {
    return activity.getTitle();
  }

  @Override
  public String getTitle() {
    Activity activity = context.getActivities().current();
    if (activity == null) {
      return "";
    }
    CharSequence title = getActivityTitle(activity);
    return (title != null) ? title.toString() : "";
  }

  @Override
  public String getWindowHandle() {
    throw new UnsupportedOperationException();
  }

  @Override
  public Set<String> getWindowHandles() {
    throw new UnsupportedOperationException();
  }

  @Override
  public Options manage() {
    return new AndroidNativeOptions();
  }

  @Override
  public Navigation navigate() {
    return new AndroidNativeNavigation();
  }

  @Override
  public void quit() {
    context.getActivities().finishAll();
  }

  @Override
  public TargetLocator switchTo() {
    throw new UnsupportedOperationException();
  }

  @Override
  public Touch getTouch() {
    return context.getTouch();
  }

  @Override
  public ScreenOrientation getOrientation() {
    int orientation = context.getOnMainSyncRunner().run(doGetOrientation());

    if ((orientation == Surface.ROTATION_0)
        || (orientation == Surface.ROTATION_180)) {
      return ScreenOrientation.PORTRAIT;
    } else { // Surface.ROTATION_90 or Surface.ROTATION_270
      return ScreenOrientation.LANDSCAPE;
    }
  }

  @Override
  public void rotate(ScreenOrientation orientation) {
    int activityOrientation;
    if (orientation == ScreenOrientation.LANDSCAPE) {
      activityOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
    } else { // ScreenOrientation.PORTRAIT
      activityOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
    }
    context.getOnMainSyncRunner().run(doRotate(activityOrientation));
  }

  /**
   * Creates a {@code Function} to get screen rotation information. This
   * {@code Function} should always be run on the main application thread.
   */
  private Function<Void, Integer> doGetOrientation() {
    return new Function<Void, Integer>() {
      @Override
      public Integer apply(Void ignoredArgument) {
        Display display
            = checkHasCurrentActivity().getWindowManager().getDefaultDisplay();

        // Display.getOrientation() is marked as deprecated starting from
        // Android 2.3. Display.getRotation() should be used in newer versions.
        return display.getOrientation();
      }
    };
  }

  /**
   * Creates a {@code Runnable} instance to rotate the screen.
   * {@code Runnable} should always be run on the main application thread.
   *
   * @param orientation a {@code ActivityInfo.SCREEN_ORIENTATION_...} value
   *        that specifies how to rotate the screen
   */
  private Runnable doRotate(final int orientation) {
    return new Runnable() {
      @Override
      public void run() {
        checkHasCurrentActivity().setRequestedOrientation(orientation);
      }
    };
  }

  private Activity checkHasCurrentActivity() {
    Activity activity = context.getActivities().current();
    if (activity == null) {
      throw new WebDriverException(
          "Current focused activity does not exist.");
    }
    return activity;
  }

  @Override
  public Keyboard getKeyboard() {
    return context.getKeySender().getKeyboard();
  }

  @Override
  @Nullable
  public Mouse getMouse() {
    return null;
  }
  
  /* (non-Javadoc)
   * @see org.openqa.selenium.HasInputDevices#actionsBuilder()
   */
  @Override
  public ActionChainsGenerator actionsBuilder() {
    return new DefaultActionChainsGenerator(this);
  }
}

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

import com.google.android.testing.nativedriver.common.Touch;
import com.google.common.base.Function;

import android.app.Activity;
import android.graphics.Rect;
import android.view.View;

import org.openqa.selenium.Dimension;
import org.openqa.selenium.ElementNotVisibleException;
import org.openqa.selenium.Point;
import org.openqa.selenium.interactions.internal.Coordinates;
import org.openqa.selenium.internal.Locatable;
import org.openqa.selenium.support.ui.TimeoutException;

import javax.annotation.Nullable;

/**
 * The default wrapper for Android views. This is extended by all other
 * view-wrappers, and is used un-extended only when a more specific view-wrapper
 * could not be found.
 *
 * <p>This class has support for operations that are the same for all
 * {@code View}s, such as {@code sendKeys}, which only requires requesting focus
 * and then sending keys through the test {@code Instrumentation}.
 *
 * <p>Note that this wrapper does not support searching child views by ID, even
 * though the {@code View} class has a {@code findViewById} method. (In order to
 * support searching child views, a class should override
 * {@code AndroidNativeElement.findElementByAndroidId}). This functionality is
 * not needed in this class, since only {@code ViewGroup} and other {@code View}
 * subclasses should have children views, and the corresponding
 * {@code ViewElement} subclasses have support for enumerating child views.
 *
 * @param <V> the {@code View} subclass that is being wrapped
 *
 * @author Matt DeVore
 * @author Dezheng Xu
 */
public class ViewElement<V extends View>
    extends AndroidNativeElement implements Locatable {
  /**
   * The literal ID used to refer to the decor view of the currently focused
   * {@code Activity}. It is equal to {@code $focusedActivity}.
   */
  public static final String LITERALID_FOCUSEDACTIVITY = "$focusedActivity";

  /**
   * A {@code ViewElementType} that represents this class.
   */
  public static final ViewElementType TYPE = new ViewElementType(View.class) {
    @Override
    public ViewElement<?> newInstance(ElementContext context, View view) {
      return new ViewElement<View>(context, view);
    }
  };

  private final V view;
  private final Coordinates coordinates;

  private class ViewCoordinates implements Coordinates {
    /**
     * {@inheritDoc}
     *
     * <p>This implementation returns the center of the {@code View}.
     */
    @Override
    public Point getLocationOnScreen() {
      Point leftTopLocation = getLocation();
      int x = leftTopLocation.x + (getViewWidth() / 2);
      int y = leftTopLocation.y + (getViewHeight() / 2);
      return new Point(x, y);
    }

    @Override
    public Point getLocationInViewPort() {
      // TODO(dxu): consider if view port matters for native app
      throw new UnsupportedOperationException();
    }

    @Override
    public Point getLocationInDOM() {
      throw new UnsupportedOperationException();
    }

    @Override
    public Object getAuxiliry() {
      // TODO(dxu): consider what could be a proper return value
      // (e.g, view or view.getId())
      throw new UnsupportedOperationException();
    }
  }

  /**
   * Constructs a new instance using the given {@code ElementContext} and
   * {@code View}.
   */
  public ViewElement(ElementContext context, V view) {
    super(context);
    this.view = view;
    coordinates = new ViewCoordinates();
  }

  protected V getView() {
    return view;
  }

  // TODO(matvore): implement getChildren() to add a child which represents
  // $contextMenu and $optionsMenu. This first requires implementing
  // AndroidNativeElement for context menus.

  /**
   * {@inheritDoc}
   *
   * This implementation returns {@code true} iff the given class exists and the
   * wrapped {@code View} is an instance of it. For instance, if
   * {@code className} is {@code "android.widget.TextView"}, then this method
   * will return {@code true} if the wrapped {@code View} is an instance of
   * {@link android.widget.TextView} or {@link android.widget.Button}.
   */
  @Override
  public boolean supportsClass(String className) {
    Class<?> searchedForClass;
    try {
      searchedForClass = Class.forName(className);
    } catch (ClassNotFoundException exception) {
      return false;
    }

    return searchedForClass.isAssignableFrom(view.getClass());
  }

  /**
   * Returns the literal ID of the wrapped {@code View}, or {@code null} if it
   * does not have one. This implementation will only return non-null if this
   * {@code View} is the decor view of the currently-focused {@code Activity},
   * in which case it returns {@code LITERALID_FOCUSEDACTIVITY}.
   */
  @Nullable
  @Override
  protected String getLiteralId() {
    if (view == decorViewOfCurrentActivity()) {
      return LITERALID_FOCUSEDACTIVITY;
    } else {
      return null;
    }
  }

  /**
   * Returns the ID of the wrapped {@code View}, or {@code null} if it does not
   * have an ID.
   */
  @Nullable
  @Override
  protected Integer getAndroidId() {
    int viewId = view.getId();
    return (viewId == View.NO_ID) ? null : viewId;
  }

  /**
   * {@inheritDoc}
   *
   * This implementation returns {@code true} iff the wrapped {@code View} does
   * not have window focus.
   *
   * @see View#hasWindowFocus()
   */
  @Override
  public boolean shouldOmitFromFindResults() {
    return !view.hasWindowFocus();
  }

  @Override
  public void click() {
    // View.isClickable() check is not needed since the actual View which
    // handles the click event might not be the one associated to current
    // ViewElement. But the coordinates should be located in the overlap area
    // of current View and the actual View that consumes the click.
    waitUntilIsDisplayed();
    scrollIntoScreenIfNeeded();
    Touch touch = context.getTouch();
    touch.tap(getCoordinates());
  }

  @Nullable
  @Override
  public AndroidNativeElement findElementByAndroidId(int id) {
    View result = view.findViewById(id);

    if (result == null) {
      return null;
    } else if (result == view) {
      return this;
    } else {
      return context.newViewElement(result);
    }
  }

  @Override
  public boolean isEnabled() {
    return view.isEnabled();
  }

  @Override
  public boolean isSelected() {
    return view.isSelected();
  }

  /**
   * Sends the given key sequence to the wrapped {@code View} by first
   * calling {@link #requestFocus()} and then sending the keys with the
   * {@link KeySender} of the {@code ElementContext}.
   */
  @Override
  public void sendKeys(CharSequence... keysToSend) {
    requestFocus();
    for (CharSequence keySubSequence : keysToSend) {
      context.getKeySender().send(keySubSequence);
    }
  }

  @Override
  public boolean isDisplayed() {
    return view.hasWindowFocus() && view.isEnabled() && view.isShown()
        && (getViewWidth() > 0) && (getViewHeight() > 0);
  }

  @Override
  public Point getLocation() {
    int[] location = new int[2];
    view.getLocationOnScreen(location);
    return new Point(location[0], location[1]);
  }

  @Override
  public Dimension getSize() {
    return new Dimension(getViewWidth(), getViewHeight());
  }

  @Override
  public Coordinates getCoordinates() {
    return coordinates;
  }

  @Override
  public Point getLocationOnScreenOnceScrolledIntoView() {
    // TODO(dxu): investigate how to use this method or handle the
    // "ScrollIntoScreenIfNeeded" case in another way. According to the
    // JavaDoc, "This method should cause the element to be scrolled into
    // view".
    throw new UnsupportedOperationException();
  }

  private void waitUntilIsDisplayed() {
    AndroidWait wait = newAndroidWait();
    // TODO(dxu): determine the proper timeout and call
    // wait.setTimeoutInMillis(timeoutInMillis), default 1000ms in AndroidWait
    try {
      wait.until(new Function<Void, Boolean>() {
        @Override
        public Boolean apply(Void input) {
          return isDisplayed();
        }
      });
    } catch (TimeoutException exception) {
      throw new ElementNotVisibleException(
          "You may only do passive read with element not displayed");
    }
  }

  protected AndroidWait newAndroidWait() {
    return new AndroidWait();
  }

  protected void scrollIntoScreenIfNeeded() {
    Point leftTopLocation = getLocation();
    int left = leftTopLocation.x;
    int top = leftTopLocation.y;
    int right = left + getViewWidth();
    int bottom = top + getViewHeight();
    requestRectangleOnScreen(new Rect(left, top, right, bottom));
  }

  protected int getViewWidth() {
    return view.getWidth();
  }

  protected int getViewHeight() {
    return view.getHeight();
  }

  /**
   * Attempts to give focus to the {@code View} that is wrapped by this
   * {@code ViewElement}. This is done synchronously on the main thread of the
   * application using the {@link Runner} in the {@code ElementContext}. If we
   * fail to get focus, issue a click to trigger. Note that the actual focused
   * {@code View} might not be the one associated to current ViewElement.
   */
  protected void requestFocus() {
    if (!context.getOnMainSyncRunner().run(doRequestFocus())) {
      click();
    }
  }

  /**
   * Request that a rectangle of this {@code View} be visible on the screen,
   * scrolling if necessary just enough. This is done synchronously on the
   * main thread of the application using the {@link Runner} in the
   * {@code ElementContext}. If we fail to get focus, issue a click to trigger.
   * Note that the actual focused {@code View} might not be the one associated
   * to current ViewElement.
   */
  protected boolean requestRectangleOnScreen(Rect rect) {
    return context.getOnMainSyncRunner()
        .run(doRequestRectangleOnScreen(rect));
  }

  private Function<Void, Boolean> doRequestFocus() {
    return new Function<Void, Boolean>() {
      @Override
      public Boolean apply(Void ignoredArgument) {
        return view.requestFocus();
      }
    };
  }

  private Function<Void, Boolean> doRequestRectangleOnScreen(final Rect rect) {
    return new Function<Void, Boolean>() {
      @Override
      public Boolean apply(Void ignoredArgument) {
        return view.requestRectangleOnScreen(rect);
      }
    };
  }

  @Nullable
  private View decorViewOfCurrentActivity() {
    Activity focusedActivity = context.getActivities().current();

    return (focusedActivity != null)
        ? focusedActivity.getWindow().getDecorView() : null;
  }
}

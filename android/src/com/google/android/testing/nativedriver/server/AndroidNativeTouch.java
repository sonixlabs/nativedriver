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
import com.google.common.base.Preconditions;

import android.app.Instrumentation;
import android.view.MotionEvent;
import android.view.ViewConfiguration;

import org.openqa.selenium.Point;
import org.openqa.selenium.WebDriverException;
import org.openqa.selenium.interactions.internal.Coordinates;
import org.openqa.selenium.support.ui.Clock;

import javax.annotation.Nullable;

/**
 * {@code Touch} interface implementation.
 *
 * @author Dezheng Xu
 */
public class AndroidNativeTouch implements Touch {
  // Use as the last argument for creating MotionEvent instance
  protected static final int DEFAULT_META_STATE = 0;

   // The duration in milliseconds before a press turns into a long press,
   // "x1.5" to ensure.
  protected static final long DURATION_OF_LONG_PRESS
      = (long) (ViewConfiguration.getLongPressTimeout() * 1.5f);

   // The duration in milliseconds between the first tap's up event and second
   // tap's down event for an interaction to be considered a double-tap.
   // "/1.5" to ensure.
  protected static final long DURATION_BETWEEN_DOUBLE_TAP
      = (long) (ViewConfiguration.getDoubleTapTimeout() / 1.5f);

  private static final long UNDEFINED_TIME = Long.MIN_VALUE;

  private final Instrumentation instrumentation;
  private final Clock clock;
  private Coordinates currentActiveCoordinates;

  // We are only accessing downTime in synchronized blocks
  private long downTime = UNDEFINED_TIME;

  public AndroidNativeTouch(Clock clock, Instrumentation instrumentation) {
    this.clock = clock;
    this.instrumentation = instrumentation;
  }

  public static AndroidNativeTouch withDefaults(
      Instrumentation instrumentation) {
    Clock clock = new AndroidSystemClock();
    return new AndroidNativeTouch(clock, instrumentation);
  }

  @Override
  public synchronized void tap(@Nullable Coordinates where) {
    if (!isTouchStateReleased()) {
      throw new IllegalStateException(
          "Attempt to tap when touch state is already down");
    }
    updateActiveCoordinates(where);
    Point point = currentActiveCoordinates.getLocationOnScreen();
    tap(point.getX(), point.getY());
  }

  @Override
  public synchronized void doubleTap(@Nullable Coordinates where) {
    if (!isTouchStateReleased()) {
      throw new IllegalStateException(
          "Attempt to double tap when touch state is already down");
    }
    updateActiveCoordinates(where);
    Point point = currentActiveCoordinates.getLocationOnScreen();
    doubleTap(point.getX(), point.getY());
  }

  @Override
  public synchronized void touchDown(@Nullable Coordinates where) {
    if (!isTouchStateReleased()) {
      throw new IllegalStateException(
          "Attempt to touch down when touch state is already down");
    }
    updateActiveCoordinates(where);
    Point point = currentActiveCoordinates.getLocationOnScreen();
    touchDown(point.getX(), point.getY());
  }

  @Override
  public synchronized void touchUp(@Nullable Coordinates where) {
    if (isTouchStateReleased()) {
      throw new IllegalStateException(
          "Attempt to release touch when touch is already released");
    }
    updateActiveCoordinates(where);
    Point point = currentActiveCoordinates.getLocationOnScreen();
    touchUp(point.getX(), point.getY());
  }

  @Override
  public synchronized void touchMove(Coordinates where) {
    Preconditions.checkNotNull(where);
    updateActiveCoordinates(where);
    if (!isTouchStateReleased()) {
      Point point = where.getLocationOnScreen();
      touchMove(point.getX(), point.getY());
    }
  }

  @Override
  public synchronized void touchMove(
      Coordinates where, long xOffset, long yOffset) {
    // Even Mouse.mouseMove(Coordinates where, long xOffset, long yOffset) is
    // not supported yet in current WebDriver implementation.
    throw new UnsupportedOperationException(
        "Moving to arbitrary (x, y) coordinates not supported.");
  }

  @Override
  public synchronized void longClick(Coordinates where) {
    if (!isTouchStateReleased()) {
      throw new IllegalStateException(
          "Attempt to longclick when touch state is already down");
    }
    updateActiveCoordinates(where);
    Point point = currentActiveCoordinates.getLocationOnScreen();
    longClick(point.getX(), point.getY());
  }

  protected void touchDown(int x, int y) {
    downTime = clock.now();
    MotionEvent motionEvent = MotionEvent.obtain(downTime, clock.now(),
        MotionEvent.ACTION_DOWN, x, y, DEFAULT_META_STATE);
    sendMotionEvent(motionEvent);
  }

  protected void touchUp(int x, int y) {
    MotionEvent motionEvent = MotionEvent.obtain(downTime, clock.now(),
        MotionEvent.ACTION_UP, x, y, DEFAULT_META_STATE);
    setTouchStateReleased();
    sendMotionEvent(motionEvent);
  }

  protected void touchMove(int x, int y) {
    MotionEvent motionEvent = MotionEvent.obtain(downTime, clock.now(),
        MotionEvent.ACTION_MOVE, x, y, DEFAULT_META_STATE);
    sendMotionEvent(motionEvent);
  }

  protected void tap(int x, int y) {
    touchDown(x, y);
    int scaledTouchSlopAdjustment = getScaledTouchSlopAdjustment();
    touchMove(x + scaledTouchSlopAdjustment, y + scaledTouchSlopAdjustment);
    touchUp(x, y);
  }

  protected void longClick(int x, int y) {
    touchDown(x, y);
    int scaledTouchSlopAdjustment = getScaledTouchSlopAdjustment();
    touchMove(x + scaledTouchSlopAdjustment, y + scaledTouchSlopAdjustment);
    sleep(DURATION_OF_LONG_PRESS);
    touchUp(x, y);
  }

  protected void doubleTap(int x, int y) {
    tap(x, y);
    sleep(DURATION_BETWEEN_DOUBLE_TAP);
    tap(x, y);
  }

  protected void sleep(long millis) {
    try {
      Thread.sleep(millis);
    } catch (InterruptedException exception) {
      Thread.currentThread().interrupt();
      throw new WebDriverException(exception);
    }
  }

  protected void sendMotionEvent(MotionEvent motionEvent) {
    instrumentation.waitForIdleSync();
    instrumentation.sendPointerSync(motionEvent);
  }

  protected boolean isTouchStateReleased() {
    return downTime == UNDEFINED_TIME;
  }

  protected int getScaledTouchSlopAdjustment() {
    int touchSlop = ViewConfiguration.get(instrumentation.getContext())
        .getScaledTouchSlop();
    return touchSlop / 2;
  }

  private void updateActiveCoordinates(Coordinates coordinates) {
    if (coordinates != null) {
      currentActiveCoordinates = coordinates;
    } else if (currentActiveCoordinates == null) {
      throw new IllegalStateException(
          "No current active coordinates and given coordinates is null.");
    }
  }

  private void setTouchStateReleased() {
    downTime = UNDEFINED_TIME;
  }

  //TODO(dxu): think about how to deal with ACTION_CANCEL
}

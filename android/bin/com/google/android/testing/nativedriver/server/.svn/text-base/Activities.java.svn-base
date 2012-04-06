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

import android.app.Activity;

import javax.annotation.Nullable;

/**
 * Supplies information on, and supports basic operations on, the
 * currently-living activities in the application. A <em>living</em>
 * activity is one that has been created and not yet destroyed.
 *
 * @author Matt DeVore
 */
public interface Activities {
  public static final int NO_ID = -1;

  /**
   * Returns a reference to the currently-focused {@code Activity}.
   * This method returns {@code null} if the last focused {@code Activity} has
   * been destroyed, or if no {@code Activity} has been focused yet.
   */
  @Nullable
  Activity current();

  /**
   * Returns the ID of the given {@code Activity}. This method returns
   * {@code NO_ID} if the activity has been destroyed, no info could be found
   * on it, or the given reference is {@code null}.
   *
   * <p>Implementors of this class must maintain a unique ID for each
   * {@code Activity} instance. The ID is included in the URL returned by
   * {@link org.openqa.selenium.WebDriver#getCurrentUrl()}, which helps tests
   * monitor activity focus changes and track activity instances.
   *
   * @param activity an {@code Activity} whose ID to get
   * @return the ID of the given {@code Activity}, or {@code NO_ID}
   */
  int idOf(@Nullable Activity activity);

  /**
   * Finishes all activities that have not been destroyed yet by calling
   * {@link Activity#finish} on each activity.
   */
  void finishAll();
}

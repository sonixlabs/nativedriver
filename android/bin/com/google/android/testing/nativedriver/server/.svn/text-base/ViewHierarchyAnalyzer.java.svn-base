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

import com.google.common.base.Preconditions;

import android.app.Activity;
import android.view.View;
import android.view.ViewParent;

import javax.annotation.Nullable;

/**
 * A class that analyzes the relationship between pairs of {@code View}s.
 *
 * @author Matt DeVore
 */
public class ViewHierarchyAnalyzer {
  private static final ViewHierarchyAnalyzer INSTANCE
      = new ViewHierarchyAnalyzer();

  public static ViewHierarchyAnalyzer getDefaultInstance() {
    return INSTANCE;
  }

  /**
   * Returns the result of {@code view.getParent()}. This is provided as an
   * overrideable method here because {@code View.getParent} is a {@code final}
   * method.
   *
   * @param view the view whose parent to return
   * @return the parent of {@code view}, or {@code null} if it has no parent
   */
  @Nullable
  protected ViewParent getViewParent(View view) {
    return view.getParent();
  }

  /**
   * Returns the result of {@code view.getParent()}. This is provided as an
   * overrideable method here because {@code ViewParent.getParent} is
   * implemented as a {@code final} method in some classes.
   *
   * @param view the view whose parent to return
   * @return the parent of {@code view}, or {@code null} if it has no parent
   */
  @Nullable
  protected ViewParent getViewParent(ViewParent view) {
    return view.getParent();
  }

  /**
   * Tests if the first {@code View} is the same as, or somewhere inside the
   * {@code View} hierarchy of, the second {@code View}.
   */
  public boolean viewIsSameOrDescendant(View child, View parent) {
    Preconditions.checkNotNull(child);
    Preconditions.checkNotNull(parent);

    if (child == parent) {
      return true;
    }

    ViewParent middleParent = getViewParent(child);

    while ((middleParent != null) && (middleParent != parent)) {
      middleParent = getViewParent(middleParent);
    }

    return middleParent == parent;
  }

  /**
   * Determines if the given {@code View} is in the main window of the given
   * {@code Activity}. If the {@code View} is in some non-main window of the
   * {@code Activity}, this method returns {@code false}.
   *
   * <p>This method works by looking at each ancestor of the given {@code View}
   * until there are no more ancestors or it finds one of the ancestors is the
   * decor view of the focused activity. It returns {@code true} if it
   * terminates on the latter case.
   *
   * <p>If {@code activity} is {@code null}, this method returns {@code false}.
   *
   * @return {@code true} if {@code view} is in the main window of the given
   *         {@code Activity}
   */
  public boolean viewIsInActivity(View view, @Nullable Activity activity) {
    return (activity != null)
        && viewIsSameOrDescendant(view, activity.getWindow().getDecorView());
  }
}

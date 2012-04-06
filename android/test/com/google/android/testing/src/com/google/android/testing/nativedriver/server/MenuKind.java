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

import com.google.common.base.Function;

import android.app.Activity;
import android.view.View;

/**
 * Represents a kind of menu. Each instance of {@code MenuElement} and
 * {@code MenuItemElement} needs to invoke either kind of menu. Generally, the
 * two menu kinds only differ in the way they are invoked, while other menu
 * logic can be implemented agnostically.
 *
 * @author Matt DeVore
 */
public enum MenuKind {
  /**
   * An options menu. An options menu is associated with an {@code Activity} but
   * not a particular {@code View}.
   */
  OPTIONS {
    /**
     * Invokes the given menu item by calling
     * {@link android.app.Instrumentation#invokeMenuActionSync
     * invokeMenuActionSync}.
     */
    @Override
    protected boolean invoke(
        ElementContext context, Activity activity, int itemId, View view) {
      return context.getInstrumentation()
          .invokeMenuActionSync(activity, itemId, 0);
    }
  },

  /**
   * A context menu. A context menu appears when
   * long-touching on a particular {@code View}, so it is associated with a
   * {@code View} and as well as the {@code Activity} that contains it.
   */
  CONTEXT {
    /**
     * Invokes the given menu item by calling
     * {@link android.app.Instrumentation#invokeContextMenuAction
     * invokeContextMenuAction}.
     */
    @Override
    protected boolean invoke(
        ElementContext context, Activity activity, int itemId, View view) {
      return context.getOnMainSyncRunner().run(requestFocus(view))
          && context.getInstrumentation()
              .invokeContextMenuAction(activity, itemId, 0);
    }
  };

  /**
   * Creates a {@code Function} to request focus for the specified view. This
   * {@code Function} should always be run on the main application thread.
   *
   * @param view the view for which the {@code Function} will request focus
   * @return a {@code Function} that requests focus and returns {@code true} if
   *         it was successful
   */
  private static Function<Void, Boolean> requestFocus(final View view) {
    return new Function<Void, Boolean>() {
      @Override
      public Boolean apply(Void ignoredArgument) {
        return view.requestFocus();
      }
    };
  }

  /**
   * Creates a {@code Function} to confirm the currently-focused activity
   * contains the specified view. This {@code Function} should always be run on
   * the main application thread.
   *
   * @param context the {@code ElementContext} to use to get the
   *        currently-focused activity and analyze the view hierarchy.
   * @param view the {@code View} to search for in the activity
   * @return a {@code Function} that confirms the focused activity, and returns
   *         a reference to the activity if successful, {@code null} if
   *         otherwise
   */
  private static Function<Void, Activity> confirmFocusedActivity(
      final ElementContext context, final View view) {
    return new Function<Void, Activity>() {
      @Override
      public Activity apply(Void ignoredArgument) {
        Activity activity = context.getActivities().current();

        return
            context.getViewHierarchyAnalyzer().viewIsInActivity(view, activity)
                ? activity : null;
      }
    };
  }

  /**
   * Clicks on the specified menu item.
   *
   * @param context the {@code ElementContext} to use to click on
   *        the menu item and run operations on the main application thread
   * @param itemId the menu item ID
   * @param view the view associated with the menu. For an options menu item,
   *        this is the decor view of the activity. For a context menu item,
   *        this is the view whose context menu to use.
   * @return {@code true} if the menu item was clicked successfully. This may
   *        fail if the {@code Activity} containing the specified {@code View}
   *        does not currently have focus.
   */
  public boolean click(ElementContext context, int itemId, View view) {
    Activity activity = context.getOnMainSyncRunner()
        .run(confirmFocusedActivity(context, view));

    return (activity != null) && invoke(context, activity, itemId, view);
  }

  /**
   * Clicks on the specified menu item, while assuming that the activity to
   * which the menu belongs already has focus.
   *
   * @param context the {@code ElementContext} to use to activate
   *        the menu item and run operations on the main application thread
   * @param activity the activity to which the menu belongs
   * @param itemId the menu item ID
   * @param view the {@code View} associated with the menu
   * @return {@code true} if the clicking operation was successful. This may
   *         fail if the menu item is disabled, or the {@code itemId} parameter
   *         is invalid.
   */
  protected abstract boolean invoke(ElementContext context,
      Activity activity, int itemId, View view);
}

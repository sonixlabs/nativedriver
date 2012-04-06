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
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Maps;

import android.app.Activity;
import android.util.Log;

import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

/**
 * Receives notification of activity events and enables manipulation of these
 * activities through an {@link Activities} object.
 *
 * @author Matt DeVore
 */
public class ActivitiesReporter {
  private static final String LOG_TAG = ActivitiesReporter.class.getName();

  @Nullable private Activities activities;
  @Nullable private Activity currentActivity;
  private final Map<Activity, Integer> liveActivities;
  private int lastAssignedId;

  private class ActivitiesImpl implements Activities {
    @Nullable
    @Override
    public Activity current() {
      return currentActivity;
    }

    @Override
    public void finishAll() {
      List<Activity> activities = ImmutableList.copyOf(liveActivities.keySet());

      for (Activity activity : activities) {
        if (liveActivities.containsKey(activity)) {
          activity.finish();
        }
      }
    }

    @Override
    public int idOf(Activity activity) {
      Integer boxedId = liveActivities.get(activity);

      return (boxedId == null) ? NO_ID : boxedId;
    }
  }

  public ActivitiesReporter() {
    liveActivities = Maps.newIdentityHashMap();
  }

  public Activities getActivities() {
    if (activities == null) {
      activities = new ActivitiesImpl();
    }

    return activities;
  }

  /**
   * Records the given {@code Activity} and assigns it an ID.
   */
  public void wasCreated(Activity activity) {
    Preconditions.checkNotNull(activity);

    liveActivities.put(activity, ++lastAssignedId);
  }

  /**
   * Records the given {@code Activity} as the currently focused one.
   */
  public void wasResumed(Activity activity) {
    Log.i(LOG_TAG, "Activity resuming of type: "
        + activity.getClass().getName());

    currentActivity = activity;
  }

  /**
   * Records the given {@code Activity} as being destroyed.
   */
  public void wasDestroyed(Activity activity) {
    Preconditions.checkNotNull(activity);

    liveActivities.remove(activity);

    if (currentActivity == activity) {
      currentActivity = null;
    }
  }
}

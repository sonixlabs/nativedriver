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

import android.os.Process;

import org.openqa.selenium.support.ui.Clock;

/**
 * A clock that uses {@code android.os.Process.getElapsedCpuTime()}.
 *
 * @author Tomohiro Kaizu
 */
public class AndroidProcessClock implements Clock {
  @Override
  public long now() {
    return Process.getElapsedCpuTime();
  }

  @Override
  public long laterBy(long durationInMillis) {
    return Process.getElapsedCpuTime() + durationInMillis;
  }

  @Override
  public boolean isNowBefore(long endInMillis) {
    return Process.getElapsedCpuTime() < endInMillis;
  }
}

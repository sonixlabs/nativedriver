/*
Copyright 2010 NativeDriver committers
Copyright 2010 Google Inc.

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

package com.google.android.testing.nativedriver.simplelayouts;

import android.app.Activity;
import android.os.Bundle;

/**
 * An activity for the Android NativeDriver (AND) tests which
 * contains a text view and text edit control.
 *
 * <p>The AND test TextValueTest kicks off the activity with the AND
 * instrumentation, then exercises AND functionality to drive the
 * activity UI. By this process we can test AND. This activity is
 * only for testing and is not intended to supply any functionality or
 * features in its own right.
 *
 * @author Matt DeVore
 */
public class TextValueActivity extends Activity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.text_value);
  }
}

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

package com.google.android.testing.nativedriver.simplelayouts;

import android.app.Activity;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

/**
 * An activity which shows two spinner controls. The first spinner shows the
 * planets of the solar system, and the second spinner shows the names of a few
 * nearby stars.
 *
 * <p>The purpose of this activity is to supply UI that can be driven with the
 * Android NativeDriver, to be used in integration tests against same tool.
 *
 * @author Matt DeVore
 */
public class SpinnersActivity extends Activity {
  @Override
  public void onCreate(Bundle savedInstance) {
    super.onCreate(savedInstance);
    setContentView(R.layout.spinners);

    Spinner planetSpinner = (Spinner) findViewById(R.id.planet_spinner);
    ArrayAdapter<CharSequence> planetAdapter = ArrayAdapter.createFromResource(
        this, R.array.planets, android.R.layout.simple_spinner_item);
    planetAdapter.setDropDownViewResource(
        android.R.layout.simple_spinner_dropdown_item);
    planetSpinner.setAdapter(planetAdapter);

    Spinner starSpinner = (Spinner) findViewById(R.id.star_spinner);
    ArrayAdapter<CharSequence> starAdapter = ArrayAdapter.createFromResource(
        this, R.array.stars, android.R.layout.simple_spinner_item);
    starAdapter.setDropDownViewResource(
        android.R.layout.simple_spinner_dropdown_item);
    starSpinner.setAdapter(starAdapter);
  }
}

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

import android.view.View;
import android.widget.TextView;

/**
 * The wrapper for Android {@code TextView}.
 *
 * @param <V> the {@code TextView} subclass that is being wrapped
 *
 * @author Dezheng Xu
 */
public class TextViewElement<V extends TextView> extends ViewElement<V> {
  /**
   * A {@code ViewElementType} that represents this class.
   */
  @SuppressWarnings("hiding")
  public static final ViewElementType TYPE
      = new ViewElementType(TextView.class) {
    @Override
    public ViewElement<?> newInstance(ElementContext context, View view) {
      return new TextViewElement<TextView>(context, (TextView) view);
    }
  };

  public TextViewElement(ElementContext context, V view) {
    super(context, view);
  }

  @Override
  public String getText() {
    return getView().getText().toString();
  }
}

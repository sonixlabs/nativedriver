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

/**
 * Represents a sequence of {@code ViewElementType}, and uses the sequence to
 * wrap {@code View}s. The "best" {@code ViewElementType} is used to wrap each
 * {@code View} by trying each {@code ViewElementType} in order and using the
 * first one that supports the {@code View}.
 *
 * @author Matt DeVore
 */
public class ViewElementFactory {
  private ViewElementType[] types;

  /**
   * Constructs a new instance using the given {@code ViewElementType}s.
   */
  public ViewElementFactory(ViewElementType... types) {
    this.types = types.clone();
  }

  private static final ViewElementFactory INSTANCE = new ViewElementFactory(
      EditTextElement.TYPE,
      TextViewElement.TYPE,
      ViewGroupElement.TYPE,
      ViewElement.TYPE);

  /**
   * Returns the default instance of {@code ViewElementFactory} that contains
   * all supported view types.
   */
  public static ViewElementFactory getDefaultInstance() {
    return INSTANCE;
  }

  /**
   * Finds the first type that supports the given {@code View} and wraps it in
   * a new instance of the supporting type. This is done using the
   * {@code ViewElementType}s passed to the constructor.
   *
   * @throw IllegalArgumentException if no type supports the given
   *        {@code View}
   */
  public ViewElement<?> newViewElement(ElementContext context, View view) {
    for (ViewElementType viewElementType : types) {
      if (viewElementType.supportsView(view)) {
        return viewElementType.newInstance(context, view);
      }
    }

    throw new IllegalArgumentException(
        "Could not find a ViewElement type that supports View: " + view);
  }
}

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
 * Represents a subclass of {@code ViewElement} that is capable of detecting
 * whether it can wrap some particular {@code View}, and can create a new
 * instance of itself that wraps some given {@code View}.
 *
 * @author Matt DeVore
 */
public abstract class ViewElementType {
  private Class<? extends View> viewClass;

  /**
   * Creates a new instance which is capable of wrapping any {@code View} that
   * is an instance of the given class.
   *
   * @param viewClass the class that all wrappable {@code View}s are an instance
   *        of
   */
  public ViewElementType(Class<? extends View> viewClass) {
    this.viewClass = viewClass;
  }

  /**
   * Indicates whether the given {@code View} can be wrapped with this
   * {@code ViewElement} implementation. The default implementation returns
   * {@code true} when the given {@code View} is an instance of the class passed
   * to the constructor.
   */
  public boolean supportsView(View view) {
    return viewClass.isInstance(view);
  }

  /**
   * Creates a new instance of this subclass of {@code ViewElement} with the
   * given context that wraps the given {@code View}.
   */
  public abstract ViewElement<?> newInstance(ElementContext context, View view);
}

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

import android.text.InputType;
import android.view.View;
import android.widget.EditText;

/**
 * The wrapper for Android {@code EditText}.
 *
 * @param <V> the {@code EditText} subclass that is being wrapped
 *
 * @author Dezheng Xu
 */
public class EditTextElement<V extends EditText> extends TextViewElement<V> {
  /**
   * A {@code ViewElementType} that represents this class.
   */
  @SuppressWarnings("hiding")
  public static final ViewElementType TYPE
      = new ViewElementType(EditText.class) {
    @Override
    public ViewElement<?> newInstance(ElementContext context, View view) {
      return new EditTextElement<EditText>(context, (EditText) view);
    }
  };

  public EditTextElement(ElementContext context, V view) {
    super(context, view);
  }

  @Override
  public void clear() {
    if (isEnabled() && (getView().getInputType() != InputType.TYPE_NULL)) {
      // Since we actually use EditText.setText(), we don't have to request
      // focus before calling that.
      context.getOnMainSyncRunner().run(doClear());
    }
  }

  /**
   * Creates a {@code Runnable} to clear the text of {@code EditText}. This
   * {@code Runnable} should always be run on the main application thread.
   */
  private Runnable doClear() {
    return new Runnable() {
      @Override
      public void run() {
        getView().setText("");
      }
    };
  }
}

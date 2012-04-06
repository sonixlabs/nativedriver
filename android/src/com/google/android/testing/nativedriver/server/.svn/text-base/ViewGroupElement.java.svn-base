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

import com.google.common.collect.AbstractIterator;

import android.view.View;
import android.view.ViewGroup;

import java.util.Iterator;

import javax.annotation.Nullable;

/**
 * The {@code ViewElement} wrapper for {@link android.view.ViewGroup}. This
 * class provides support for enumerating children by overriding
 * {@link AndroidNativeElement#getChildren}.
 *
 * @param <V> the {@code ViewGroup} subclass that is being wrapped
 *
 * @author Matt DeVore
 */
public class ViewGroupElement<V extends ViewGroup> extends ViewElement<V> {
  /**
   * A {@code ViewElementType} that represents this class.
   */
  @SuppressWarnings("hiding")
  public static final ViewElementType TYPE
      = new ViewElementType(ViewGroup.class) {
    @Override
    public ViewElement<?> newInstance(ElementContext context, View view) {
      return new ViewGroupElement<ViewGroup>(context, (ViewGroup) view);
    }
  };

  private Iterable<ViewElement<?>> childrenIterable;

  private class ChildrenIterator extends AbstractIterator<ViewElement<?>> {
    private int childIndex = 0;

    @Nullable
    @Override
    protected ViewElement<?> computeNext() {
      View nextView = getView().getChildAt(childIndex++);

      return (nextView != null)
          ? context.newViewElement(nextView)
          : endOfData();
    }
  }

  private class ChildrenIterable implements Iterable<ViewElement<?>> {
    @Override
    public Iterator<ViewElement<?>> iterator() {
      return new ChildrenIterator();
    }
  }

  public ViewGroupElement(ElementContext context, V view) {
    super(context, view);
  }

  @Override
  public Iterable<? extends AndroidNativeElement> getChildren() {
    if (childrenIterable == null) {
      childrenIterable = new ChildrenIterable();
    }

    return childrenIterable;
  }
}

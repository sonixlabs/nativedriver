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

import javax.annotation.Nullable;

/**
 * Represents a collection of elements that can be covered in a search performed
 * by {@code AndroidDriver.findElement(s)} or
 * {@code AndroidNativeElement.findElement(s)}.
 *
 * @author Matt DeVore
 */
public interface ElementSearchScope {
  /**
   * Returns an {@code Iterable} of all top-level elements in this scope.
   *
   * <p>Not all scopes support enumerating all elements. In this case, this
   * method should only return the elements it is capable of enumerating.
   *
   * @return an {@code Iterable} containing the children of this element
   */
  Iterable<? extends AndroidNativeElement> getChildren();

  /**
   * Finds an element corresponding to the given Android ID, which is the value
   * returned by methods such as {@code View.getId} and
   * {@code MenuItem.getItemId}. This usually corresponds to a field in the
   * {@code R.id} class. This method should search the search scope root, its
   * children, and its non-direct descendants. If the result is the search scope
   * root, the returned object should compare equal to this instance of
   * {@code ElementSearchScope} with the {@code equals} method.
   *
   * @param id the Android ID of the item to find
   * @return a reference to the element that was found, or {@code null} if no
   *         corresponding element was found
   */
  @Nullable
  AndroidNativeElement findElementByAndroidId(int id);
}

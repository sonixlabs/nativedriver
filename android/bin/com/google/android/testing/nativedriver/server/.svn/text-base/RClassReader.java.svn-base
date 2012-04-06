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

package com.google.android.testing.nativedriver.server;

import com.google.common.collect.ImmutableList;

import java.util.List;

import javax.annotation.Nullable;

/**
 * Reads the public static int fields in the inner classes of
 * R classes. This is necessary to support searching for Views
 * using the string View ID.
 *
 * <p>The Android NativeDriver server uses reflection to find the integer value
 * of View IDs given as strings by the client (i.e. test code). For any project,
 * IDs for controls are take from at least two R classes: {@code android.R} and
 * {@code <app package name>.R}. Therefore, this class supports searching more
 * than one R class in sequence. The value is returned from the first R class in
 * which the value is found.
 *
 * @author Matt DeVore
 */
public class RClassReader {
  private final List<String> rClassNames;

  /**
   * Constructs a new instance which reads the fields of the inner classes of
   * the given R classes.
   *
   * @param rClassNames the full class names of the R classes from which to
   * read. Each string should generally end with ".R" but this is not required.
   */
  public RClassReader(String... rClassNames) {
    this.rClassNames = ImmutableList.copyOf(rClassNames);
  }

  /**
   * Search this instance's R classes for the given field in the given inner
   * class. This method will not throw an exception if the search failed in some
   * predictable way. For instance when an R class cannot be loaded, the field
   * is not an integer, or a field with the given name is not found in any R
   * class, {@code null} will be returned.
   *
   * @param innerClass the inner class to search, for instance "id".
   * @param fieldName the field for which to search, for instance
   *        "TextView01"
   * @return a boxed integer containing the value of the R field, or
   *         {@code null} if anything went wrong.
   */
  @Nullable
  public Integer getRField(String innerClass, String fieldName) {
    for (String rClassName : rClassNames) {
      String fullClassName = rClassName + "$" + innerClass;

      Integer fieldValue = getRFieldFromClass(fullClassName, fieldName);

      if (fieldValue != null) {
        return fieldValue;
      }
    }

    return null;
  }

  public List<String> getRClassNames() {
    return rClassNames;
  }

  @Nullable
  private static Integer getRFieldFromClass(String fullClassName,
      String fieldName) {
    try {
      Class<?> r = Class.forName(fullClassName);

      Object fieldValue = r.getField(fieldName).get(null);

      if (!(fieldValue instanceof Integer)) {
        return null;
      }

      return (Integer) fieldValue;
    } catch (NullPointerException exception) {
      return null;
    } catch (ClassNotFoundException exception) {
      return null;
    } catch (NoSuchFieldException exception) {
      return null;
    } catch (IllegalAccessException exception) {
      return null;
    }
  }
}

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

import com.google.common.base.Function;

import javax.annotation.Nullable;

/**
 * Runs operations represented by {@code Runnable}s and {@code Function}s.
 *
 * @author Matt DeVore
 */
public abstract class Runner {
  private static class FunctionRunnable<F, T> implements Runnable {
    @Nullable private F input;
    @Nullable private T output;
    private Function<F, T> function;

    public FunctionRunnable(Function<F, T> function, @Nullable F input) {
      this.function = function;
      this.input = input;
    }

    @Override
    public void run() {
      output = function.apply(input);
    }

    @Nullable
    public T getOutput() {
      return output;
    }
  }

  /**
   * Runs the operation represented by a {@code Runnable}.
   */
  public abstract void run(Runnable runnable);

  /**
   * Runs the operation represented by a {@code Function}, taking one argument
   * and returning a value.
   *
   * @param function the function to execute
   * @param argument the argument to pass to {@code function.apply}
   * @return the value returned by {@code function.apply}
   */
  @Nullable
  public <F, T> T run(Function<F, T> function, @Nullable F argument) {
    FunctionRunnable<F, T> operation
        = new FunctionRunnable<F, T>(function, argument);

    run(operation);

    return operation.getOutput();
  }

  /**
   * Equivalent to {@code run(function, argument)}, but uses
   * {@code null} as the value for {@code argument}. This is useful for
   * {@code Function}s that ignore their argument.
   */
  @Nullable
  public <T> T run(Function<?, T> function) {
    return run(function, null);
  }
}

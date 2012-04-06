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

import com.google.android.testing.nativedriver.common.Touch;

import android.app.Instrumentation;
import android.view.View;

/**
 * A class that supplies contextual information about
 * {@code AndroidNativeElement}s. This information is needed to facilitate
 * {@code View}-finding and UI-driving operations. For instance,
 * {@code ServerInstrumentation} is needed to allow
 * {@code AndroidNativeElement}s to call {@code sendStringSync} and
 * {@code invokeContextMenuAction} on it.
 *
 * <p>In production, this information is unchanged between all instances
 * of {@code AndroidNativeElement} for a given {@code AndroidNativeDriver}.
 *
 * @author Matt DeVore
 * @author Tomohiro Kaizu
 * @author Dezheng Xu
 */
public class ElementContext {
  private final Activities activities;
  private final ElementFinder elementFinder;
  private final Instrumentation instrumentation;
  private final KeySender keySender;
  private final Runner onMainSyncRunner;
  private final Touch touch;
  private final ViewElementFactory viewElementFactory;
  private final ViewHierarchyAnalyzer viewHierarchyAnalyzer;

  public ElementContext(
      Activities activities,
      ElementFinder elementFinder,
      Instrumentation instrumentation,
      KeySender keySender,
      Runner onMainSyncRunner,
      Touch touch,
      ViewElementFactory viewElementFactory,
      ViewHierarchyAnalyzer viewHierarchyAnalyzer) {
    this.activities = activities;
    this.elementFinder = elementFinder;
    this.instrumentation = instrumentation;
    this.keySender = keySender;
    this.onMainSyncRunner = onMainSyncRunner;
    this.touch = touch;
    this.viewElementFactory = viewElementFactory;
    this.viewHierarchyAnalyzer = viewHierarchyAnalyzer;
  }

  public static ElementContext withDefaults(
      ServerInstrumentation instrumentation) {
    RClassReader rClassReader;
    if (instrumentation != null) {
      rClassReader = new RClassReader(instrumentation.getTargetContext()
          .getPackageName() + ".R", "android.R");
    } else {
      rClassReader = new RClassReader("android.R");
    }

    return new ElementContext(
        instrumentation.getActivities(),
        new ElementFinder(rClassReader, new AndroidWait()),
        instrumentation,
        new KeySender(instrumentation),
        new OnMainSyncRunner(instrumentation),
        AndroidNativeTouch.withDefaults(instrumentation),
        ViewElementFactory.getDefaultInstance(),
        ViewHierarchyAnalyzer.getDefaultInstance());
  }

  public Activities getActivities() {
    return activities;
  }

  public ElementFinder getElementFinder() {
    return elementFinder;
  }

  public KeySender getKeySender() {
    return keySender;
  }

  public Instrumentation getInstrumentation() {
    return instrumentation;
  }

  public Runner getOnMainSyncRunner() {
    return onMainSyncRunner;
  }

  public Touch getTouch() {
    return touch;
  }

  /**
   * Returns the {@code ViewElementFactory} used to find the best wrapper for a
   * given Android {@code View}, which is necessary for creating new instances
   * of {@code ViewElement}.
   */
  public ViewElementFactory getViewElementFactory() {
    return viewElementFactory;
  }

  public ViewHierarchyAnalyzer getViewHierarchyAnalyzer() {
    return viewHierarchyAnalyzer;
  }

  /**
   * Wraps a {@code View} in a new instance of {@code ViewElement} using the
   * most appropriate wrapper class available. This is accomplished by using the
   * {@code viewElementFactory} instance that was passed to the constructor.
   *
   * @param viewToWrap the {@code View} to wrap
   * @return a reference to a new {@code ViewElement} that wraps the
   *         {@code View}
   */
  public ViewElement<? extends View> newViewElement(View viewToWrap) {
    return viewElementFactory.newViewElement(this, viewToWrap);
  }
}

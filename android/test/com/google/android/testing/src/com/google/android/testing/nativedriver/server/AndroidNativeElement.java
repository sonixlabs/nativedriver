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

import com.google.common.collect.ImmutableList;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.RenderedWebElement;
import org.openqa.selenium.SearchContext;
import org.openqa.selenium.WebElement;

import java.util.List;

import javax.annotation.Nullable;

/**
 * Superclass of all {@code WebElement} implementations in the Android
 * NativeDriver. This class provides the following functionality:
 * <ul>
 *   <li>Behavior for each {@code WebElement} operation that is appropriate for
 *   an element that does not support the operation. For instance, calling
 *   {@code clear} on an uneditable element is a no-op, so the {@code clear}
 *   implementation of this class is also a no-op.
 *   <li>A field of type {@link ElementContext} to store contextual
 *   information.
 * </ul>
 *
 * @author Matt DeVore
 * @author Dezheng Xu
 */
public abstract class AndroidNativeElement
    implements ElementSearchScope, RenderedWebElement, SearchContext {
  protected final ElementContext context;
  @Nullable private SearchContext searchContext;

  public AndroidNativeElement(ElementContext context) {
    this.context = context;
  }

  /**
   * Checks if this element supports the given class. This is used to implement
   * the {@link org.openqa.selenium.internal.FindsByClassName} interface.
   *
   * @param className the class name to check if supported by the element
   * @return {@code true} iff this element supports the specified class
   */
  public abstract boolean supportsClass(String className);


  /**
   * {@inheritDoc}
   *
   * <p>This implementation returns an empty {@code Iterable}.
   */
  @Override
  public Iterable<? extends AndroidNativeElement> getChildren() {
    return ImmutableList.of();
  }

  /**
   * {@inheritDoc}
   *
   * <p>This implementation returns {@code null}.
   */
  @Nullable
  @Override
  public AndroidNativeElement findElementByAndroidId(int id) {
    return null;
  }

  /**
   * Returns the literal ID by which this element can be referred. See the
   * class documentation for an explanation of the semantics of literal IDs. If
   * this element does not have a literal ID, this method returns {@code null},
   * which is the behavior of this default implementation.
   *
   * @return the literal ID by which this element can be referred, or
   *         {@code null} if this element has no literal ID
   */
  @Nullable
  protected String getLiteralId() {
    return null;
  }

  /**
   * Returns the Android ID by which this element can be referred as a boxed
   * integer. This may be, for instance, a {@code View} ID or a {@code MenuItem}
   * ID.
   *
   * @return the Android ID by which this element can be referred, or
   *         {@code null} if this element has no Android ID
   */
  @Nullable
  protected Integer getAndroidId() {
    return null;
  }

  /**
   * Indicates whether this element should be omitted from find results. This
   * is important if the element matches the find criteria (such as ID or text)
   * but for some reason is not useful as a find result.
   *
   * <p>This default implementation always returns {@code false}.
   *
   * @return {@code true} if this element should be omitted from search results,
   *         {@code false} otherwise
   */
  public boolean shouldOmitFromFindResults() {
    return false;
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation is a no-op.
   */
  @Override
  public void clear() {
    // no-op
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation is a no-op.
   */
  @Override
  public void click() {
    // no-op
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation returns {@code null}, as if there are no
   * attributes defined.
   */
  @Nullable
  @Override
  public String getAttribute(String name) {
    return null;
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation returns the simple name of this
   * {@code Object}'s class.
   */
  @Override
  public String getTagName() {
    return getClass().getSimpleName();
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation returns an empty string
   */
  @Override
  public String getText() {
    return "";
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation returns {@code getAttribute("value")}.
   */
  @Deprecated
  @Nullable
  @Override
  public String getValue() {
    return getAttribute("value");
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation returns {@code true}.
   */
  @Override
  public boolean isEnabled() {
    return true;
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation returns {@code false}.
   */
  @Override
  public boolean isSelected() {
    return false;
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation is a no-op.
   */
  @Override
  public void sendKeys(CharSequence... keysToSend) {
    // no-op
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation is a no-op.
   */
  @Override
  public void setSelected() {
    // no-op
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation throws a {@code NoSuchElementException}, which
   * indicates this element is not part of a form.
   *
   * @throw NoSuchElementException
   */
  @Override
  public void submit() {
    throw new NoSuchElementException("This element is not part of a form.");
  }

  /**
   * {@inheritDoc}
   *
   * This default implementation is a no-op that returns the value returned by
   * {@code isSelected}.
   */
  @Override
  public boolean toggle() {
    // no-op
    return isSelected();
  }

  private SearchContext getSearchContext() {
    if (searchContext == null) {
      searchContext = context.getElementFinder().getSearchContext(this);
    }

    return searchContext;
  }

  @Override
  public WebElement findElement(By by) {
    return getSearchContext().findElement(by);
  }

  @Override
  public List<WebElement> findElements(By by) {
    return getSearchContext().findElements(by);
  }

  @Deprecated
  @Override
  public void dragAndDropBy(int moveRightBy, int moveDownBy) {
    throw new UnsupportedOperationException();
  }

  @Deprecated
  @Override
  public void dragAndDropOn(RenderedWebElement element) {
    throw new UnsupportedOperationException();
  }

  @Override
  public String getValueOfCssProperty(String propertyName) {
    throw new UnsupportedOperationException();
  }
}

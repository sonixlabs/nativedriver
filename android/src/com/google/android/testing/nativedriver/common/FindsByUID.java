package com.google.android.testing.nativedriver.common;

import org.openqa.selenium.WebElement;

/**
 * An interface implemented by {@link org.openqa.selenium.SearchContext}s which
 * represents the ability to find elements by uniqueId. The methods on this
 * interface are used in the same way as the methods on the standard
 *
 * @author Kazuhiro Yamada
 */
public interface FindsByUID {
  /**
   * The name of the find-by-uid strategy as used in the JSON protocol.
   */
  String USING_UID = "uid";

  WebElement findElementByUID(String using);
}

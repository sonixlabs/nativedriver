package com.google.android.testing.nativedriver.server.handler;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

import org.openqa.selenium.By;
import org.openqa.selenium.remote.server.DriverSessions;
import org.openqa.selenium.remote.server.JsonParametersAware;
import org.openqa.selenium.remote.server.handler.WebDriverHandler;
import org.openqa.selenium.remote.server.rest.ResultType;

import android.widget.EditText;

import com.google.android.testing.nativedriver.server.EditTextElement;

/**
 * A handler to send key events via Android Instrumentation to the
 * currently-running process.
 *
 * @author Kazuhiro Yamada
 */
public class SetText extends WebDriverHandler
    implements JsonParametersAware {
  private final List<CharSequence> keys
      = new CopyOnWriteArrayList<CharSequence>();

  private CharSequence value;
  private volatile String elementId;

  public SetText(DriverSessions sessions) {
    super(sessions);
  }
  
  public void setId(String elementId) {
    this.elementId = elementId;
  }

  @Override
  @SuppressWarnings({"unchecked"})
  public void setJsonParameters(Map<String, Object> allParameters)
      throws Exception {
    System.out.println("====SetText===");
    value = (CharSequence) allParameters.get("value");
    System.out.println("value:" + value);
    
    
    
//    List<String> rawKeys = (List<String>) allParameters.get("value");
//    List<String> temp = Lists.newArrayList();
//
//    for (String key : rawKeys) {
//      temp.add(key);
//    }
//    keys.addAll(temp);
    
    
  }

  @SuppressWarnings("unchecked")
  @Override
  public ResultType call() throws Exception {
//    String[] keysToSend = keys.toArray(new String[0]);
//    ((HasInputDevices) getDriver()).getKeyboard().sendKeys(keysToSend);
    ((EditTextElement<EditText>)(getKnownElements().get(this.elementId))).setText(value);
    
//    getDriver().findElement(By.id(this.elementId))
    return ResultType.SUCCESS;
  }

  @Override
  public String toString() {
    return String.format("[send keys: %s]", value);
  }
}

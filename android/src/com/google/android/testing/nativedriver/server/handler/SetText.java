package com.google.android.testing.nativedriver.server.handler;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

import org.openqa.selenium.remote.server.DriverSessions;
import org.openqa.selenium.remote.server.JsonParametersAware;
import org.openqa.selenium.remote.server.handler.WebDriverHandler;
import org.openqa.selenium.remote.server.rest.ResultType;

import com.google.android.testing.nativedriver.common.HasSetText;

/**
 * A handler to send key events via Android Instrumentation to the
 * currently-running process.
 *
 * @author Kazuhiro Yamada
 */
public class SetText extends WebDriverHandler
    implements JsonParametersAware {
  private final List<CharSequence> keys = new CopyOnWriteArrayList<CharSequence>();

  private CharSequence value;
  private volatile String elementId;

  public SetText(DriverSessions sessions) {
    super(sessions);
  }
  
  public void setId(String elementId) {
    this.elementId = elementId;
  }

  @Override
  public void setJsonParameters(Map<String, Object> allParameters)
      throws Exception {
    System.out.println("====SetText===");
    value = (CharSequence) allParameters.get("value");
    System.out.println("value:" + value);
    System.out.println("elementId:" + this.elementId);
    
  }

  @Override
  public ResultType call() throws Exception {
//    String[] keysToSend = keys.toArray(new String[0]);
//    ((HasInputDevices) getDriver()).getKeyboard().sendKeys(keysToSend);
//    WebElement e = getKnownElements().get(this.elementId);
//    EditTextElement<EditText> ed = (EditTextElement<EditText>)(getKnownElements().get(this.elementId));
//    System.out.println("EditTextElement:" + ed);
//    ed.setText(value);
	System.out.println("ver:6");
//    ((AndroidNativeElement)getKnownElements().get(this.elementId)).setText(value);
//    getRootSearchContext
//    ((AndroidNativeDriver)this.getDriver()).getRootSearchContext().
//	System.out.println("cp0");
//	System.out.println(getDriver().toString());
//    ElementContext context = ((HasSetText) getDriver()).getContext();
//	System.out.println("cp1");
//    RootSearchScope scope = new RootSearchScope(context);
//	System.out.println("cp2");
//    scope.findElementByAndroidId(Integer.parseInt(this.elementId)).setText(value);
//    scope.findElementByAndroidId(1).setText(value);
	
//	 ((HasTouchScreen) getDriver()).setText(elementId, "test");
    ((HasSetText) getDriver()).setText(elementId, "SetText");
    
//    ((EditTextElement<EditText>)(getKnownElements().get(this.elementId))).setText(value);
//    getDriver().findElement(By.id(this.elementId))
    return ResultType.SUCCESS;
  }

  @Override
  public String toString() {
    return String.format("[setText: %s]", value);
  }
}

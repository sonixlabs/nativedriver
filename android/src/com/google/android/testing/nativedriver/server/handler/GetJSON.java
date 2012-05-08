package com.google.android.testing.nativedriver.server.handler;

import java.util.Map;

import org.openqa.selenium.remote.Response;
import org.openqa.selenium.remote.server.JsonParametersAware;
import org.openqa.selenium.remote.server.Session;
import org.openqa.selenium.remote.server.handler.WebDriverHandler;
import org.openqa.selenium.remote.server.rest.ResultType;

public class GetJSON extends WebDriverHandler implements
    JsonParametersAware {
  private volatile String url;
  private volatile Response response;

  public GetJSON(Session session) {
    super(session);
  }

  @Override
  public void setJsonParameters(Map<String, Object> allParameters)
      throws Exception {
    url = (String) allParameters.get("url");
  }

  @Override
  public ResultType call() throws Exception {
    response = newResponse();
    Object json = getDriver().getJson(url);
    response.setValue(json);
    return ResultType.SUCCESS;
  }

  public Response getResponse() {
    return response;
  }

  @Override
  public String toString() {
    return String.format("[getJson: url(%s) ]", url);
  }
}

package com.google.android.testing.nativedriver.client;

import java.net.URL;
import java.util.Map;

import org.openqa.selenium.remote.HttpCommandExecutor;

import com.google.android.testing.nativedriver.common.AndroidNativeDriverCommand;

public class AndroidNativeHttpCommandExecutor extends HttpCommandExecutor implements AndroidNativeDriverCommand{

  public AndroidNativeHttpCommandExecutor(URL addressOfRemoteServer) {
    super(addressOfRemoteServer);
  }
  
  public Map<String, CommandInfo> getNameToUrlMap() { 
    Map<String, CommandInfo> map = super.getNameToUrlMap();
    map.put(DRAG_ELEMENT, post("/session/:sessionId/element/:id/dragElement"));
    return map;
  }
  
}

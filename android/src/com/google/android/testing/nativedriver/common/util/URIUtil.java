package com.google.android.testing.nativedriver.common.util;

import java.util.HashMap;
import java.util.Map;

/**
 * @author Kazuhiro Yamada
 */
public class URIUtil {
  public static Map<String, String> getQueryMap(String query)  
  {  
      if (query == null) {
        return null;
      }
      String[] params = query.split("&");  
      Map<String, String> map = new HashMap<String, String>();  
      for (String param : params)  
      {  
          String name = param.split("=")[0];  
          String value = param.split("=")[1];  
          map.put(name, value);  
      }  
      return map;  
  } 
}

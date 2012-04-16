package com.google.android.testing.nativedriver.client;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

public class AdbService {
    
    private String adbPath;
    
    private String packageInfo;
    
    public AdbService(String adbPath, String packageInfo) {
        this.adbPath = adbPath;
        this.packageInfo = packageInfo;
    }
    
    public String instrument() {
        StringBuilder command = new StringBuilder();
        command.append(getAdbPath());
        command.append(" shell am instrument ");
        command.append(getPackageInfo());
        command.append("/com.google.android.testing.nativedriver.server.ServerInstrumentation");
        String result = exeCommand(command.toString());
        return result;
    }
    
    public String forward() {
        StringBuilder command = new StringBuilder();
        command.append(getAdbPath());
        command.append(" forward tcp:54129 tcp:54129");
        String result = exeCommand(command.toString());
        return result;
    }
    
    public String dropData() {
        StringBuilder command = new StringBuilder();
        command.append(getAdbPath());
        command.append(" shell pm clear ");
        command.append(getPackageInfo());
        String result = exeCommand(command.toString());
        return result;
    }
    
    private String exeCommand(String command) {
        StringBuilder result = new StringBuilder();
        try {
            Process process = Runtime.getRuntime().exec(command);
            process.waitFor();
            InputStream is = process.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            String line;
            while ((line = br.readLine()) != null) {
                result.append(line);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println(command + " : " + result.toString());
        return result.toString();
    }
    
    private String getAdbPath() {
        return this.adbPath;
    }
    
    private String getPackageInfo() {
        return this.packageInfo;
    }
}

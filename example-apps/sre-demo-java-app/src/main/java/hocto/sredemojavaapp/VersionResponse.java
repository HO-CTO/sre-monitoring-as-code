package hocto.sredemojavaapp;

public class VersionResponse {

    private static String runtime = System.getProperty("java.runtime.name");
    private static String version = System.getProperty("java.version");
    
    public String getRuntime() {
        return runtime;
    }

    public String getVersion() {
        return version;
    }

}

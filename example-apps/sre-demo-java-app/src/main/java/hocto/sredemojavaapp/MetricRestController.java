package hocto.sredemojavaapp;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MetricRestController {


    @CrossOrigin(origins = "*")
    @GetMapping(value = "/version")
    public VersionResponse handleVersion() {
        return new VersionResponse();
    }

    private static class VersionResponse {
        private static final String runtime = System.getProperty("java.runtime.name");
        private static final String version = System.getProperty("java.version");

        public String getRuntime() {
            return runtime;
        }

        public String getVersion() {
            return version;
        }
    }
}
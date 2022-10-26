package hocto.sredemojavaapp;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MetricRestController {


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
	@CrossOrigin(origins = "*")
	@GetMapping(value = "/version")
	public VersionResponse handleVersion() {
		return new VersionResponse();
	}
}
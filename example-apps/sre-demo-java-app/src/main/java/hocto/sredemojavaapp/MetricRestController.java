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

	private MetricService metricService;

	public MetricRestController(MetricService metricService) {
		this.metricService = metricService;
	}

	@CrossOrigin(origins = "*")
	@GetMapping("/values")
	public SimpleCounterMetricResponse index() {
		return new SimpleCounterMetricResponse(metricService.getSuccessValue(), metricService.getExceptionsValue(), metricService.getTotalValue());
	}

	@CrossOrigin(origins = "*")
	@RequestMapping(value = "/success", method = RequestMethod.POST, produces = "application/json")
	public SimpleCounterMetricResponse handleSuccess(@RequestBody SimpleCounterMetricRequest request) {
		this.metricService.incrementSuccessCounter(request.getAmount());
		return new SimpleCounterMetricResponse(metricService.getSuccessValue(), metricService.getExceptionsValue(), metricService.getTotalValue());
	}

	@CrossOrigin(origins = "*")
	@RequestMapping(value = "/exception", method = RequestMethod.POST, produces = "application/json")
	public SimpleCounterMetricResponse handleException(@RequestBody SimpleCounterMetricRequest request) {
		this.metricService.incrementExceptionCounter(request.getAmount());
		return new SimpleCounterMetricResponse(metricService.getSuccessValue(), metricService.getExceptionsValue(), metricService.getTotalValue());
	}

	@CrossOrigin(origins = "*")
	@GetMapping(value = "/version")
	public VersionResponse handleVersion() {
		return new VersionResponse();
	}
}
package hocto.sredemojavaapp;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
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
	@RequestMapping(value = "/success", method = RequestMethod.POST)
	public SimpleCounterMetricResponse handleSuccess(@RequestParam(defaultValue = "1", name = "amount") String amount) {
		this.metricService.incrementSuccessCounter(Double.parseDouble(amount));
		return new SimpleCounterMetricResponse(metricService.getSuccessValue(), metricService.getExceptionsValue(), metricService.getTotalValue());
	}

	@CrossOrigin(origins = "*")
	@RequestMapping(value = "/exception", method = RequestMethod.POST)
	public SimpleCounterMetricResponse handleException(@RequestParam(defaultValue = "1", name = "amount") String amount) {
		this.metricService.incrementExceptionCounter(Double.parseDouble(amount));
		return new SimpleCounterMetricResponse(metricService.getSuccessValue(), metricService.getExceptionsValue(), metricService.getTotalValue());
	}

}
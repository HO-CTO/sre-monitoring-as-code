package hocto.sredemojavaapp;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class MetricRestController {

	private MetricService metricService;

	public MetricRestController(MetricService metricService) {
		this.metricService = metricService;
	}

	@GetMapping("/")
	public String index(Model model) {
		model.addAttribute("successful", metricService.getSuccessValue());
		model.addAttribute("exceptions", metricService.getExceptionsValue());
		model.addAttribute("total", metricService.getTotalValue());

		return "index";
	}

	@RequestMapping(value = "/success", method = RequestMethod.POST)
	public String handleSuccess(@RequestParam(defaultValue = "1", name = "amount") String amount) {
		this.metricService.incrementSuccessCounter(Double.parseDouble(amount));
		return "redirect:/";
	}

	@RequestMapping(value = "/exception", method = RequestMethod.POST)
	public String handleException(@RequestParam(defaultValue = "1", name = "amount") String amount) {
		this.metricService.incrementExceptionCounter(Double.parseDouble(amount));
		return "redirect:/";
	}

}
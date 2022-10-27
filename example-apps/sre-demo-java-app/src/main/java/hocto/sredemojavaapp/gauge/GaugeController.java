package hocto.sredemojavaapp.gauge;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(path = "/gauges")
@CrossOrigin(origins = "*")
public class GaugeController {

    private final GaugeService gaugeService;

    public GaugeController(GaugeService gaugeService) {
        this.gaugeService = gaugeService;
    }

    @GetMapping("")
    public List<GaugePOJO> listGauges() {
        return gaugeService.listGauges();
    }

    @GetMapping("/{name}")
    public GaugePOJO getGauge(@PathVariable String name) {
        return gaugeService.getGauge(name);
    }

    @PostMapping("")
    public GaugePOJO createGauge(@RequestBody CreateGaugeRequestBody body) {
        return gaugeService.createGauge(body.getName(), body.getLabels(), body.getValue());
    }

    @DeleteMapping("/{name}")
    public GaugePOJO deleteGauge(@PathVariable String name) {
        return gaugeService.deleteGauge(name);
    }

    @PostMapping("/{name}/increment")
    public GaugePOJO incrementGauge(@PathVariable String name, @RequestBody GaugeChangeRequestBody body) {
        return gaugeService.incrementGauge(name, body.getLabels(), body.getValue());
    }

    @PostMapping("/{name}/decrement")
    public GaugePOJO decrementGauge(@PathVariable String name, @RequestBody GaugeChangeRequestBody body) {
        return gaugeService.decrementGauge(name, body.getLabels(), body.getValue());
    }

    @PutMapping("/{name}")
    public GaugePOJO setGauge(@PathVariable String name, @RequestBody GaugeChangeRequestBody body) {
        return gaugeService.setGauge(name, body.getLabels(), body.getValue());
    }

}

package hocto.sredemojavaapp.histogram;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(path = "/histograms")
@CrossOrigin(origins = "*")
public class HistogramController {

    private final HistogramService histogramService;

    public HistogramController(HistogramService histogramService) {
        this.histogramService = histogramService;
    }

    @GetMapping("")
    public List<HistogramPOJO> listHistograms() {
        return histogramService.listHistograms();
    }

    @GetMapping("/{name}")
    public HistogramPOJO getHistogram(@PathVariable String name) {
        return histogramService.getHistogram(name);
    }

    @PostMapping("")
    public HistogramPOJO createHistogram(@RequestBody CreateHistogramRequestBody body) {
        return histogramService.createHistogram(body.getName(), body.getLabels(), body.getInitialValue(), body.getBuckets());
    }

    @DeleteMapping("/{name}")
    public HistogramPOJO deleteHistogram(@PathVariable String name) {
        return histogramService.deleteHistogram(name);
    }


    @PostMapping("/{name}/observe")
    public HistogramPOJO observe(@PathVariable String name, @RequestBody HistogramObserveRequestBody body) {
        return histogramService.observe(name, body.getLabels(), body.getValue());
    }

}

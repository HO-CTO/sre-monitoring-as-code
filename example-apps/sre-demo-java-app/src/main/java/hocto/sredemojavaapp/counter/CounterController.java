package hocto.sredemojavaapp.counter;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(path = "/counters")
@CrossOrigin(origins = "*")
public class CounterController {

    private final CounterService counterService;

    public CounterController(CounterService counterService) {
        this.counterService = counterService;
    }

    @GetMapping("")
    public List<CounterPOJO> listCounters() {
        return counterService.listCounters();
    }

    @GetMapping("/{name}")
    public CounterPOJO getCounter(@PathVariable String name) {
        return counterService.getCounter(name);
    }

    @PostMapping("")
    public CounterPOJO createCounter(@RequestBody CreateCounterRequestBody body) {
        return counterService.createCounter(body.getName(), body.getLabels(), body.getValue());
    }

    @DeleteMapping("/{name}")
    public CounterPOJO deleteCounter(@PathVariable String name) {
        return counterService.deleteCounter(name);
    }

    @PostMapping("/{name}/increment")
    public CounterPOJO incrementCounter(@PathVariable String name, @RequestBody CounterIncrementRequestBody body) {
        return counterService.incrementCounter(name, body.getLabels(), body.getValue());
    }

}

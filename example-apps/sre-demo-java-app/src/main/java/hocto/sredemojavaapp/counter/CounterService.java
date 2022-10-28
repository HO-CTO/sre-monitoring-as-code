package hocto.sredemojavaapp.counter;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class CounterService {

    private final CounterDAO counterDAO;

    public CounterService(CounterDAO counterDAO) {
        this.counterDAO = counterDAO;
    }

    public List<CounterPOJO> listCounters() {
        return counterDAO.listCounters();
    }

    public CounterPOJO getCounter(String name) {
        return counterDAO.getCounter(name);
    }

    public CounterPOJO createCounter(String name, Map<String, String> labels, Double initialValue) {
        return counterDAO.createCounter(name, labels, initialValue);
    }

    public CounterPOJO deleteCounter(String name) {
        return counterDAO.deleteCounter(name);
    }

    public CounterPOJO incrementCounter(String name, Map<String, String> labels, Double value) {
        return counterDAO.incrementCounter(name, labels, value);
    }
}

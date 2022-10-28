package hocto.sredemojavaapp.counter;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Tag;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class CounterDAO {

    private final MeterRegistry meterRegistry;
    private final List<String> createdCounters;

    public CounterDAO(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.createdCounters = new ArrayList<>();
    }


    private List<Tag> mapToTags(Map<String, String> map) {
        return List.of(
                map.entrySet().stream().map(entry -> Tag.of(entry.getKey(), entry.getValue())).toArray(Tag[]::new)
        );
    }

    private Map<String, String> tagsToMap(List<Tag> tags) {
        return Map.ofEntries(
                tags.stream().map(tag -> Map.entry(tag.getKey(), tag.getValue())).toArray(Map.Entry[]::new)
        );
    }

    public List<CounterPOJO> listCounters() {
        return meterRegistry.getMeters().stream()
                .filter(meter -> this.createdCounters.contains(meter.getId().getName()))
                .map(meter -> new CounterPOJO(meter.getId().getName(), new CounterPOJO.CounterValue(tagsToMap(meter.getId().getTags()), ((Counter) meter).count()))).collect(Collectors.toList());
    }

    public CounterPOJO getCounter(String name) {
        final Counter counter = meterRegistry.find(name).counter();
        if (counter == null) {
            throw new RuntimeException(String.format("No counter with name \"%s\" found", name));
        }

        return new CounterPOJO(counter.getId().getName(), new CounterPOJO.CounterValue(tagsToMap(counter.getId().getTags()), counter.count()));
    }

    public CounterPOJO createCounter(String name, Map<String, String> labels, Double initialValue) {

        Counter.Builder builder = Counter.builder(name);
        labels.forEach(builder::tag);
        Counter newCounter = builder.register(meterRegistry);

        if (initialValue != null) {
            newCounter.increment(initialValue);
        }

        this.createdCounters.add(name);

        double value = meterRegistry.find(name).counter().count();
        return new CounterPOJO(name, new CounterPOJO.CounterValue(labels, value));
    }

    public CounterPOJO deleteCounter(String name) {
        final Counter counter = meterRegistry.find(name).counter();
        if (counter == null) {
            throw new RuntimeException(String.format("No counter with name \"%s\" found", name));
        }

        final CounterPOJO result = new CounterPOJO(
                counter.getId().getName(),
                new CounterPOJO.CounterValue(tagsToMap(counter.getId().getTags()),
                        counter.count())

        );

        createdCounters.remove(counter.getId().getName());
        meterRegistry.remove(counter.getId());

        return result;
    }

    public CounterPOJO incrementCounter(String name, Map<String, String> labels, Double value) {
        final Counter counter = meterRegistry.find(name).tags(mapToTags(labels)).counter();
        if (counter == null) {
            throw new RuntimeException(String.format("No counter with name \"%s\" found", name));
        }

        counter.increment(value);

        return new CounterPOJO(counter.getId().getName(), new CounterPOJO.CounterValue(tagsToMap(counter.getId().getTags()), counter.count()));
    }
}

package hocto.sredemojavaapp.gauge;

import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Tag;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Component
public class GaugeDAO {

    private final MeterRegistry meterRegistry;
    private final List<GaugeSensor> createdGauges;

    public GaugeDAO(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.createdGauges = new ArrayList<>();
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

    public List<GaugePOJO> listGauges() {
        return meterRegistry.getMeters().stream()
                .filter(
                        meter -> this.createdGauges.stream()
                                .filter(sensor -> sensor.getName().equals(meter.getId().getName())).toList().size() > 0
                )
                .map(meter ->
                        new GaugePOJO(
                                meter.getId().getName(),
                                new GaugePOJO.GaugeValue(tagsToMap(meter.getId().getTags()),
                                        ((Gauge) meter).value()))
                ).collect(Collectors.toList()
                );
    }

    public GaugePOJO getGauge(String name) {
        final Gauge gauge = meterRegistry.find(name).gauge();
        if (gauge == null) {
            throw new RuntimeException(String.format("No gauge with name \"%s\" found", name));
        }

        return new GaugePOJO(gauge.getId().getName(), new GaugePOJO.GaugeValue(tagsToMap(gauge.getId().getTags()), gauge.value()));
    }

    public GaugePOJO createGauge(String name, Map<String, String> labels, int initialValue) {

        GaugeSensor gaugeSensor = new GaugeSensor(name, initialValue);
        Gauge.Builder<GaugeSensor> builder = Gauge.builder(gaugeSensor.getName(), gaugeSensor, GaugeSensor::getValue).strongReference(true);
        labels.forEach(builder::tag);
        this.createdGauges.add(gaugeSensor);
        builder.register(meterRegistry);

        gaugeSensor.setValue(initialValue);

        double value = Objects.requireNonNull(meterRegistry.find(name).gauge()).value();
        return new GaugePOJO(name, new GaugePOJO.GaugeValue(labels, value));
    }

    public GaugePOJO deleteGauge(String name) {
        final Gauge gauge = meterRegistry.find(name).gauge();
        if (gauge == null) {
            throw new RuntimeException(String.format("No gauge with name \"%s\" found", name));
        }

        final GaugePOJO result = new GaugePOJO(
                gauge.getId().getName(),
                new GaugePOJO.GaugeValue(tagsToMap(gauge.getId().getTags()),
                        gauge.value())

        );
        createdGauges.removeIf(gaugeSensor -> gaugeSensor.getName().equals(name));
        meterRegistry.remove(gauge.getId());

        return result;
    }

    public GaugePOJO incrementGauge(String name, Map<String, String> labels, int value) {

        final Gauge gauge = meterRegistry.find(name).tags(mapToTags(labels)).gauge();
        if (gauge == null) {
            throw new RuntimeException(String.format("No gauge with name \"%s\" found", name));
        }

        Optional<GaugeSensor> sensor = createdGauges.stream().filter(gs -> gs.getName().equals(name)).findFirst();
        sensor.ifPresent(gaugeSensor -> gaugeSensor.setValue(gaugeSensor.getValue() + value));

        return new GaugePOJO(gauge.getId().getName(), new GaugePOJO.GaugeValue(tagsToMap(gauge.getId().getTags()), gauge.value()));
    }

    public GaugePOJO decrementGauge(String name, Map<String, String> labels, int value) {
        final Gauge gauge = meterRegistry.find(name).tags(mapToTags(labels)).gauge();
        if (gauge == null) {
            throw new RuntimeException(String.format("No gauge with name \"%s\" found", name));
        }

        Optional<GaugeSensor> sensor = createdGauges.stream().filter(gs -> gs.getName().equals(name)).findFirst();
        sensor.ifPresent(gaugeSensor -> gaugeSensor.setValue(gaugeSensor.getValue() - value));

        return new GaugePOJO(gauge.getId().getName(), new GaugePOJO.GaugeValue(tagsToMap(gauge.getId().getTags()), gauge.value()));
    }

    public GaugePOJO setGauge(String name, Map<String, String> labels, int value) {
        final Gauge gauge = meterRegistry.find(name).tags(mapToTags(labels)).gauge();
        if (gauge == null) {
            throw new RuntimeException(String.format("No gauge with name \"%s\" found", name));
        }

        Optional<GaugeSensor> sensor = createdGauges.stream().filter(gs -> gs.getName().equals(name)).findFirst();
        sensor.ifPresent(gaugeSensor -> gaugeSensor.setValue(value));

        return new GaugePOJO(gauge.getId().getName(), new GaugePOJO.GaugeValue(tagsToMap(gauge.getId().getTags()), gauge.value()));
    }

    public static class GaugeSensor {

        private final String name;
        private final AtomicInteger value;

        public GaugeSensor(String name, int value) {
            this.name = name;
            this.value = new AtomicInteger(value);
        }

        public String getName() {
            return name;
        }

        public int getValue() {
            return value.get();
        }

        public void setValue(int value) {
            this.value.set(value);
        }
    }
}

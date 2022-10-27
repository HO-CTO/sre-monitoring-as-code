package hocto.sredemojavaapp.histogram;

import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Tag;
import io.micrometer.core.instrument.distribution.CountAtBucket;
import io.micrometer.core.instrument.distribution.HistogramSnapshot;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

@Component
public class HistogramDAO {

    private final MeterRegistry meterRegistry;
    private final List<String> createdHistograms;

    public HistogramDAO(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.createdHistograms = new ArrayList<>();
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

    public List<HistogramPOJO> listHistograms() {
        return meterRegistry.getMeters().stream()
                .filter(
                        meter -> this.createdHistograms.contains(meter.getId().getName())
                )
                .map(meter ->
                        new HistogramPOJO(
                                meter.getId().getName(),
                                tagsToMap(meter.getId().getTags()),
                                getHistogramValues(meter.getId().getName(), tagsToMap(meter.getId().getTags()))
                        )).collect(Collectors.toList());
    }

    public HistogramPOJO getHistogram(String name) {
        final DistributionSummary histogram = meterRegistry.find(name).summary();
        if (histogram == null) {
            throw new RuntimeException(String.format("No gauge with name \"%s\" found", name));
        }

        return new HistogramPOJO(histogram.getId().getName(), tagsToMap(histogram.getId().getTags()), getHistogramValues(histogram.getId().getName(), tagsToMap(histogram.getId().getTags())));
    }

    public HistogramPOJO createHistogram(String name, Map<String, String> labels, Double initialValue, List<Double> buckets) {

        DistributionSummary.Builder builder = DistributionSummary.builder(name)
                .publishPercentileHistogram()
                .percentilePrecision(5);
        labels.forEach(builder::tag);

        if (buckets != null) {
            builder.serviceLevelObjectives(buckets.stream().mapToDouble(Double::doubleValue).toArray());
        } else {
            builder.serviceLevelObjectives(1, 10).minimumExpectedValue(1d).maximumExpectedValue(10d);
        }

        DistributionSummary histogram = builder.register(meterRegistry);

        this.createdHistograms.add(name);

        if (initialValue != null) {
            histogram.record(initialValue);
        }

        List<HistogramPOJO.HistogramValue> histogramValues = getHistogramValues(name, labels);

        return new HistogramPOJO(name, labels, histogramValues);
    }

    private List<HistogramPOJO.HistogramValue> getHistogramValues(String name, Map<String, String> labels) {
        DistributionSummary summary = meterRegistry.find(name).tags(mapToTags(labels)).summary();
        HistogramSnapshot histogramSnapshot = summary.takeSnapshot();
        CountAtBucket[] histogramCounts = histogramSnapshot.histogramCounts();
        double sum = histogramSnapshot.total();
        double count = histogramSnapshot.count();

        List<HistogramPOJO.HistogramValue> histogramValues = Arrays.stream(histogramCounts).map(
                        countAtBucket -> new HistogramPOJO.HistogramValue(
                                name.concat("_bucket"),
                                countAtBucket.count(),
                                addBucketToLabels(labels, String.valueOf(countAtBucket.bucket()))))
                .collect(Collectors.toList());

        histogramValues.add(new HistogramPOJO.HistogramValue(name.concat("_sum"), sum, labels));
        histogramValues.add(new HistogramPOJO.HistogramValue(name.concat("_count"), count, labels));
        return histogramValues;
    }

    private Map<String, String> addBucketToLabels(Map<String, String> labels, String bucketValue) {
        final Map<String, String> result = new HashMap<>();
        result.putAll(labels);
        result.put("le", bucketValue);
        return result;
    }

    public HistogramPOJO deleteHistogram(String name) {
        final DistributionSummary histogram = meterRegistry.find(name).summary();
        if (histogram == null) {
            throw new RuntimeException(String.format("No gauge with name \"%s\" found", name));
        }

        final HistogramPOJO result = new HistogramPOJO(
                histogram.getId().getName(),
                tagsToMap(histogram.getId().getTags()),
                getHistogramValues(histogram.getId().getName(), tagsToMap(histogram.getId().getTags()))
        );
        createdHistograms.removeIf(histogramName -> histogramName.equals(name));
        meterRegistry.remove(histogram.getId());

        return result;
    }

    public HistogramPOJO observeValue(String name, Map<String, String> labels, double value) {

        final DistributionSummary histogram = meterRegistry.find(name).tags(mapToTags(labels)).summary();
        if (histogram == null) {
            throw new RuntimeException(String.format("No gauge with name \"%s\" found", name));
        }

        histogram.record(value);

        final HistogramPOJO result = new HistogramPOJO(
                histogram.getId().getName(),
                tagsToMap(histogram.getId().getTags()),
                getHistogramValues(histogram.getId().getName(), tagsToMap(histogram.getId().getTags()))
        );

        return result;
    }


}

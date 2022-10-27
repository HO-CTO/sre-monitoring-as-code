package hocto.sredemojavaapp.histogram;

import java.util.List;
import java.util.Map;

public class CreateHistogramRequestBody {
    private String name;
    private String description;
    private Map<String, String> labels;
    private List<Double> buckets;

    private Double initialValue;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Map<String, String> getLabels() {
        return labels;
    }

    public void setLabels(Map<String, String> labels) {
        this.labels = labels;
    }

    public List<Double> getBuckets() {
        return buckets;
    }

    public void setBuckets(List<Double> buckets) {
        this.buckets = buckets;
    }

    public Double getInitialValue() {
        return initialValue;
    }

    public void setInitialValue(Double initialValue) {
        this.initialValue = initialValue;
    }

    @Override
    public String toString() {
        return "CreateHistogramRequestBody{" +
                "name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", labels=" + labels +
                ", buckets=" + buckets +
                ", initialValue=" + initialValue +
                '}';
    }
}

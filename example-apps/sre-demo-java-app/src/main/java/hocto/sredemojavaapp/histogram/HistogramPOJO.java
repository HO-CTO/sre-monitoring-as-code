package hocto.sredemojavaapp.histogram;

import java.util.List;
import java.util.Map;

public class HistogramPOJO {

    List<HistogramValue> value;
    private String name;
    private Map<String, String> labels;

    public HistogramPOJO(String name) {
        this.name = name;
    }

    public HistogramPOJO(String name, Map<String, String> labels) {
        this.name = name;
        this.labels = labels;
    }

    public HistogramPOJO(String name, Map<String, String> labels, List<HistogramValue> values) {
        this.name = name;
        this.labels = labels;
        this.value = values;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Map<String, String> getLabels() {
        return labels;
    }

    public void setLabels(Map<String, String> labels) {
        this.labels = labels;
    }

    public List<HistogramValue> getValue() {
        return value;
    }

    public void setValue(List<HistogramValue> value) {
        this.value = value;
    }

    public static class HistogramValue {

        Map<String, String> labels;
        Double value;
        private String name;

        public HistogramValue(String name, Double count, Map<String, String> labels) {
            this.name = name;
            this.value = count;
            this.labels = labels;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public Map<String, String> getLabels() {
            return labels;
        }

        public void setLabels(Map<String, String> labels) {
            this.labels = labels;
        }

        public Double getValue() {
            return value;
        }

        public void setValue(Double value) {
            this.value = value;
        }
    }
}

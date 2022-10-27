package hocto.sredemojavaapp.gauge;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class GaugePOJO {
    private String name;
    private List<GaugeValue> value;

    public GaugePOJO(String name, GaugeValue value) {
        this.name = name;
        this.value = new ArrayList<>();
        this.value.add(value);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<GaugeValue> getValue() {
        return value;
    }

    public void setValue(List<GaugeValue> value) {
        this.value = value;
    }

    public static class GaugeValue {
        private Map<String, String> labels;
        private Double value;

        public GaugeValue(Map<String, String> labels, Double value) {
            this.labels = labels;
            this.value = value;
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

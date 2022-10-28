package hocto.sredemojavaapp.counter;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CounterPOJO {

    private String name;
    private List<CounterValue> value;

    public CounterPOJO(String name, CounterValue value) {
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

    public List<CounterValue> getValue() {
        return value;
    }

    public void setValue(List<CounterValue> value) {
        this.value = value;
    }

    public static class CounterValue {
        private Map<String, String> labels;
        private Double value;

        CounterValue(Map<String, String> labels, Double value) {

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

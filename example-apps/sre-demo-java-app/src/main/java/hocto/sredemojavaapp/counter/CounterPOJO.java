package hocto.sredemojavaapp.counter;

import java.util.List;
import java.util.Map;

public class CounterPOJO {
    private String name;
    private Map<String, String> labels;
    private Double value;

    public CounterPOJO(String name) {
        this.name = name;
    }

    public CounterPOJO(String name, Map<String, String>  labels) {
        this.name = name;
        this.labels = labels;
    }

    public CounterPOJO(String name, Map<String, String>  labels, Double value) {
        this.name = name;
        this.labels = labels;
        this.value = value;
    }

    public CounterPOJO() {

    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Map<String, String>  getLabels() {
        return labels;
    }

    public void setLabels(Map<String, String>  labels) {
        this.labels = labels;
    }

    public Double getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }
}

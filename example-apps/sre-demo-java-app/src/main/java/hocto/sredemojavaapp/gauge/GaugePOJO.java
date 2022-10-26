package hocto.sredemojavaapp.gauge;

import java.util.Map;

public class GaugePOJO {
    private String name;
    private Map<String, String> labels;
    private Double value;

    public GaugePOJO(String name) {
        this.name = name;
    }

    public GaugePOJO(String name, Map<String, String>  labels) {
        this.name = name;
        this.labels = labels;
    }

    public GaugePOJO(String name, Map<String, String>  labels, Double value) {
        this.name = name;
        this.labels = labels;
        this.value = value;
    }

    public GaugePOJO() {

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

package hocto.sredemojavaapp.counter;

import java.io.Serializable;
import java.util.Map;

public class CreateCounterRequestBody implements Serializable {

    private String name;
    private Map<String, String> labels;
    private Double value;

    public CreateCounterRequestBody() {
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

    @Override
    public String toString() {
        return "CreateCounterRequestBody{" +
                "name='" + name + '\'' +
                ", labels=" + labels +
                ", value=" + value +
                '}';
    }
}

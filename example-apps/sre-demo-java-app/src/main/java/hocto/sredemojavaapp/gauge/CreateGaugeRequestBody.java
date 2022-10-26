package hocto.sredemojavaapp.gauge;

import java.util.Map;

public class CreateGaugeRequestBody {

    private String name;
    private Map<String, String> labels;
    private int value;

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

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return "CreateGaugeRequestBody{" +
                "name='" + name + '\'' +
                ", labels=" + labels +
                ", value=" + value +
                '}';
    }
}

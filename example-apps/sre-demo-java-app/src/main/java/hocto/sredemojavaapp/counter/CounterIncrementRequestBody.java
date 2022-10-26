package hocto.sredemojavaapp.counter;

import java.util.Map;

public class CounterIncrementRequestBody {

    private Map<String, String> labels;
    private Double value;

    public CounterIncrementRequestBody() {
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

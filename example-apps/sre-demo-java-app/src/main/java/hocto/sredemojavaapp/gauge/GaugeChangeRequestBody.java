package hocto.sredemojavaapp.gauge;

import java.util.Map;

public class GaugeChangeRequestBody {

    private Map<String, String> labels;
    private int value;

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
}

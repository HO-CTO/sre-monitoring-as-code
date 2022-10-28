package hocto.sredemojavaapp.gauge;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class GaugeService {

    private final GaugeDAO gaugeDAO;

    public GaugeService(GaugeDAO gaugeDAO) {
        this.gaugeDAO = gaugeDAO;
    }

    public List<GaugePOJO> listGauges() {
        return gaugeDAO.listGauges();
    }

    public GaugePOJO getGauge(String name) {
        return gaugeDAO.getGauge(name);
    }

    public GaugePOJO createGauge(String name, Map<String, String> labels, int initialValue) {
        return gaugeDAO.createGauge(name, labels, initialValue);
    }

    public GaugePOJO deleteGauge(String name) {
        return gaugeDAO.deleteGauge(name);
    }

    public GaugePOJO incrementGauge(String name, Map<String, String> labels, int value) {
        return gaugeDAO.incrementGauge(name, labels, value);
    }

    public GaugePOJO decrementGauge(String name, Map<String, String> labels, int value) {
        return gaugeDAO.decrementGauge(name, labels, value);
    }

    public GaugePOJO setGauge(String name, Map<String, String> labels, int value) {
        return gaugeDAO.setGauge(name, labels, value);
    }
}

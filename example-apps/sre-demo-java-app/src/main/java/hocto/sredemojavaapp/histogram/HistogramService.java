package hocto.sredemojavaapp.histogram;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class HistogramService {

    private final HistogramDAO histogramDAO;

    public HistogramService(HistogramDAO histogramDAO) {
        this.histogramDAO = histogramDAO;
    }

    public List<HistogramPOJO> listHistograms() {
        return histogramDAO.listHistograms();
    }

    public HistogramPOJO getHistogram(String name) {
        return histogramDAO.getHistogram(name);
    }

    public HistogramPOJO createHistogram(String name, Map<String, String> labels, Double initialValue, List<Double> buckets) {
        return histogramDAO.createHistogram(name, labels, initialValue, buckets);
    }

    public HistogramPOJO deleteHistogram(String name) {
        return histogramDAO.deleteHistogram(name);
    }

    public HistogramPOJO observe(String name, Map<String, String> labels, Double value) {
        return histogramDAO.observeValue(name, labels, value);
    }
}

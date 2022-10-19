package hocto.sredemojavaapp;

import java.io.Serializable;

public class SimpleCounterMetricResponse implements Serializable {
    
    private double good;
    private double bad;
    private double total;

    public SimpleCounterMetricResponse(double good, double bad, double total) {
        this.good = good;
        this.bad = bad;
        this.total = total;
    }   

    public double getGood() {
        return good;
    }


    public void setGood(double good) {
        this.good = good;
    }


    public double getBad() {
        return bad;
    }


    public void setBad(double bad) {
        this.bad = bad;
    }


    public double getTotal() {
        return total;
    }


    public void setTotal(double total) {
        this.total = total;
    }
}

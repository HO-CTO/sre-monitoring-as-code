package hocto.sredemojavaapp;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;

import org.springframework.stereotype.Component;

@Component
public class MetricService {

    private MeterRegistry meterRegistry;
    private Counter successful;
    private Counter exceptions;

    public MetricService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.initCounter();
    }

    private void initCounter() {
        successful = Counter.builder("simple.counter")
            .tag("status", "SUCCESS")
            .description("A demo counter metric")
            .register(meterRegistry);

        exceptions = Counter.builder("simple.counter")
            .tag("status", "EXCEPTION")
            .description("A demo counter metric")
            .register(meterRegistry);
    }

    public void incrementSuccessCounter(double amount) {
        successful.increment(amount);
    }

    public void incrementExceptionCounter(double amount) {
        exceptions.increment(amount);
    }

    public double getSuccessValue() {
        return successful.count();
    }

    public double getExceptionsValue() {
        return exceptions.count();
    }

    public double getTotalValue() {
        return successful.count() + exceptions.count();
    }
}

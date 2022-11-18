interface MetricType {
    name: string;
}

interface AWSMetricType {
    name: string;
    namespace: string;
    metrics: AWSMetric[];
}

interface AWSMetric {
    metricName: string;
    metricType: string;
}
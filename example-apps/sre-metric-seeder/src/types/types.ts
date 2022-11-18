interface MetricType {
    name: string;
    serviceType: ServiceType;
    config:  AWSMetricType | HTTPMetricType;
}

enum ServiceType {
    AWS,
    HTTP,
}

type configType = AWSMetricType | HTTPMetricType;

// ===========================================

interface AWSMetric {
    metricName: string;
    metricType: string;
}

interface AWSMetricType {
    namespace: string;
    metrics: AWSMetric[];
}

// ===========================================

interface HTTPMetricType{
    uri: string;
    method: String;
    data: object;
}


interface AWSCommandBuilderInput {
    namespace: string;
    metricName: string;
    value: number;
}

export const buildCommand = ({namespace, metricName, value}: AWSCommandBuilderInput) => {
    return `awslocal cloudwatch put-metric-data --namespace \"${namespace}\" --metric-data '[{\"MetricName\": \"${metricName}\", \"Value\": ${value}}}]'`;
}
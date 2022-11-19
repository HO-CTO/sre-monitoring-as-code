import "../types/types"

interface AWSCommandBuilderInput {
    namespace: string;
    metricName: string;
    value: number;
}

const singleCommand = ({namespace, metricName, value}: AWSCommandBuilderInput) => {
    return `awslocal cloudwatch put-metric-data --namespace \"${namespace}\" --metric-data '[{\"MetricName\": \"${metricName}\", \"Value\": ${value}}}]'`;
}

export const buildCommand =({namespace, metrics}: AWSMetricType ): string[] => {

    let strings: string[] = [];
    metrics.forEach(element => {
        strings.push(singleCommand({namespace, metricName: element.metricName, value:10}))
    });

    return strings;
}
/*

inherits envoker.ts

var enokedString = input
main
    call envoke

*/

interface AWSCommandBuilderInput {
    namespace: string;
    metricName: string;
    value: number;
}

const invoke = ({namespace, metricName, value}: AWSCommandBuilderInput) => {
    const command = `awslocal cloudwatch put-metric-data --namespace \"${namespace}\" --metric-data '[{\"MetricName\": \"${metricName}\", \"Value\": ${value}}}]'`;
}
import './types/types'

export const metricTypes: MetricType[] = [
    { name: "alb", serviceType: ServiceType.AWS, config: {namespace: "AWS/ALB", metrics: []} },
    { name: "es", serviceType: ServiceType.AWS, config: {namespace: "AWS/ES", metrics: []}},
    { name: "s3", serviceType: ServiceType.AWS, config: { namespace: "AWS/S3", metrics: []}},
    { name: "sqs", serviceType: ServiceType.AWS, config: { namespace: "AWS/SQS", metrics: [
        { metricName: "ApproximateNumberOfMessagesVisible", metricType: "Count" },
        { metricName: "ApproximateAgeOfOldestMessage", metricType: "Count" },
        { metricName: "NumberOfMessagesSent", metricType: "Count" },
        { metricName: "NumberOfMessagesDeleted", metricType: "Count" },
    ]},
    },
    { name: "rds", serviceType: ServiceType.AWS, config: {namespace: "AWS/RDS", metrics: []} },
]
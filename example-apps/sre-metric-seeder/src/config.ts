const metricTypes: AWSMetricType[] = [
    { name: "alb", namespace: "AWS/ALB", metrics: [] },
    { name: "es", namespace: "AWS/ES", metrics: []},
    { name: "s3", namespace: "AWS/S3", metrics: []},
    { name: "sqs", namespace: "AWS/SQS", metrics: [
        { metricName: "ApproximateNumberOfMessagesVisible", metricType: "Count" },
        { metricName: "ApproximateAgeOfOldestMessage", metricType: "Count" },
        { metricName: "NumberOfMessagesSent", metricType: "Count" },
        { metricName: "NumberOfMessagesDeleted", metricType: "Count" },

    ]},
    { name: "rds", namespace: "AWS/RDS", metrics: []},
];
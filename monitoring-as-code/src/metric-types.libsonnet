// This file is for storing the config of the metric types

// File exports
// The different types of metrics and their config
{
  'http_server_requests_seconds': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
        resource: 'uri',
        errorStatus: 'status',
      },
      metrics: {
        sum: 'http_server_requests_seconds_sum',
        count: 'http_server_requests_seconds_count',
        bucket: 'http_server_requests_seconds_bucket',
      },
      outboundSelectorLabels: {
        environment: 'namespace',
        product: 'job',
        resource: 'uri',
        errorStatus: 'status',
      },
      outboundMetrics: {
        count: 'http_client_requests_seconds_count',
        bucket: 'http_client_requests_seconds_bucket',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-availability-promclient.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          count: 'count',
        },
      },
      latency: {
        library: (import 'sli-metric-libraries/sli-latency-promclient.libsonnet'),
        description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          sum: 'sum',
          count: 'count',
          bucket: 'bucket',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability', 'httpRequestsLatency'],
      targetMetrics: {
        count: 'count',
        bucket: 'bucket',
      },
    },
  },
  'grafana_http_request_duration_seconds': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
        resource: 'handler',
        errorStatus: 'status_code',
      },
      metrics: {
        count: 'grafana_http_request_duration_seconds_count',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-availability-promclient.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          count: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability'],
      targetMetrics: {
        count: 'count',
      },
    },
  },
  'http_requests_total': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
        resource: 'handler',
        errorStatus: 'code',
      },
      metrics: {
        count: 'http_requests_total',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-availability-promclient.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          count: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability'],
      targetMetrics: {
        count: 'count',
      },
    },
  },
  'http_request_duration_seconds': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
        resource: 'handler',
      },
      metrics: {
        sum: 'http_request_duration_seconds_sum',
        count: 'http_request_duration_seconds_count',
        bucket: 'http_request_duration_seconds_bucket',
      },
    },
    sliTypesConfig: {
      latency: {
        library: (import 'sli-metric-libraries/sli-latency-promclient.libsonnet'),
        description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          sum: 'sum',
          count: 'count',
          bucket: 'bucket',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource'],
      elements: ['httpRequestsLatency'],
      targetMetrics: {
        bucket: 'bucket',
      },
    },
  },
  'nginx_ingress_controller_requests': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'exported_namespace',
        product: 'exported_service',
        errorStatus: 'status',
      },
      metrics: {
        count: 'nginx_ingress_controller_requests',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-availability-promclient.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          count: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['errorStatus'],
      elements: ['httpRequestsAvailability'],
      targetMetrics: {
        count: 'count',
      },
    },
  },
  'nginx_ingress_controller_request_duration_seconds': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'exported_namespace',
        product: 'exported_service',
        errorStatus: 'status',
      },
      metrics: {
        sum: 'nginx_ingress_controller_request_duration_seconds_sum',
        count: 'nginx_ingress_controller_request_duration_seconds_count',
        bucket: 'nginx_ingress_controller_request_duration_seconds_bucket',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-availability-promclient.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          count: 'count',
        },
      },
      latency: {
        library: (import 'sli-metric-libraries/sli-latency-promclient.libsonnet'),
        description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          sum: 'sum',
          count: 'count',
          bucket: 'bucket',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['errorStatus'],
      elements: ['httpRequestsAvailability', 'httpRequestsLatency'],
      targetMetrics: {
        count: 'count',
        bucket: 'bucket',
      },
    },
  },
  'aws_alb': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        count4xx: 'aws_alb_httpcode_target_4_xx_count_sum',
        count5xx: 'aws_alb_httpcode_target_5_xx_count_sum',
        requestCount: 'aws_alb_request_count_sum',
        responseTime: 'aws_alb_target_response_time',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-availability-cloudwatch-alb.libsonnet'),
        description: 'The error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          count4xx: 'count4xx',
          count5xx: 'count5xx',
          requestCount: 'requestCount',
        },
      },
      latency: {
        library: (import 'sli-metric-libraries/sli-latency-cloudwatch-alb.libsonnet'),
        description: 'Target latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          responseTime: 'responseTime',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  'aws_sqs': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        messagesVisible: 'aws_sqs_approximate_number_of_messages_visible_sum',
        oldestMessage: 'aws_sqs_approximate_age_of_oldest_message_sum',
        messagesSent: 'aws_sqs_number_of_messages_sent_sum',
        messagesDeleted: 'aws_sqs_number_of_messages_deleted_sum',
      },
      customSelectorLabels: {
        deadletterQueueName: 'queue_name',
        deadletterQueueType: 'queue_type',
        targetQueue: 'dimension_QueueName',
      },
      customSelectors: {
        deadletterQueueName: '.+dlq.+',
        deadletterQueueType: 'deadletter',
      },
    },
    sliTypesConfig: {
      freshness: {
        library: (import 'sli-metric-libraries/sli-freshness-cloudwatch-sqs.libsonnet'),
        description: 'Age of oldest message in SQS queue should be less than %(metricTarget)s seconds for %(sliDescription)s',
        targetMetrics: {
          oldestMessage: 'oldestMessage',
          messagesDeleted: 'messagesDeleted',
        },
      },
      correctness: {
        library: (import 'sli-metric-libraries/sli-correctness-cloudwatch-sqs-dlq.libsonnet'),
        description: 'There should be no messages in the DLQ for %(sliDescription)s',
        targetMetrics: {
          messagesVisible: 'messagesVisible',
          oldestMessage: 'oldestMessage',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: ['cloudwatchSqs'],
      targetMetrics: {
        oldestMessage: 'oldestMessage',
        messagesDeleted: 'messagesDeleted',
        messagesVisible: 'messagesVisible',
        messagesSent: 'messagesSent',
      },
    },
  },
  'thanos_compact_group_compactions': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        totalFailures: 'thanos_compact_group_compactions_failures_total',
        total: 'thanos_compact_group_compactions_total',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-availability-generic.libsonnet'),
        description: 'The rate of %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          totalFailures: 'totalFailures',
          total: 'total',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  'up': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
      },
      metrics: {
        duration: 'up',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-avgovertime-generic.libsonnet'),
        description: 'The average of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          duration: 'duration',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  'scrape_duration_seconds': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        duration: 'scrape_duration_seconds',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-metric-libraries/sli-avgovertime-generic.libsonnet'),
        description: 'The average of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          duration: 'duration',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  'aws_rds_read': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        averageLatency: 'aws_rds_read_latency_average',
        averageIops: 'aws_rds_read_iops_average',
        averageThroughput: 'aws_rds_read_throughput_average',
      },
    },
    sliTypesConfig: {
      latency: {
        library: (import 'sli-metric-libraries/sli-average-metric.libsonnet'),
        description: 'The average latency of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          average: 'averageLatency',
        },
      },
      iops: {
        library: (import 'sli-metric-libraries/sli-average-metric.libsonnet'),
        description: 'The average IOPS of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          average: 'averageIops',
        },
      },
      throughput: {
        library: (import 'sli-metric-libraries/sli-average-metric.libsonnet'),
        description: 'The average throughput of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          average: 'averageThroughput',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  'aws_rds_write': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        averageLatency: 'aws_rds_write_latency_average',
        averageIops: 'aws_rds_write_iops_average',
        averageThroughput: 'aws_rds_write_throughput_average',
      },
    },
    sliTypesConfig: {
      latency: {
        library: (import 'sli-metric-libraries/sli-average-metric.libsonnet'),
        description: 'The average latency of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          average: 'averageLatency',
        },
      },
      iops: {
        library: (import 'sli-metric-libraries/sli-average-metric.libsonnet'),
        description: 'The average IOPS of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          average: 'averageIops',
        },
      },
      throughput: {
        library: (import 'sli-metric-libraries/sli-average-metric.libsonnet'),
        description: 'The average throughput of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          average: 'averageThroughput',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  'aws_es': {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        averageLatency: 'aws_es_search_latency_average',
      },
    },
    sliTypesConfig: {
      latency: {
        library: (import 'sli-metric-libraries/sli-average-metric.libsonnet'),
        description: 'The average latency of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          average: 'averageLatency',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
}

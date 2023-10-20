// This file is for storing the config of the metric types

// File exports
// The different types of metrics and their config
{
  http_server_requests_seconds: {
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
        library: (import 'sli-value-libraries/availability-counter-using-single-metric-for-both-num-and-dem-filtered-by-status-label.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'count',
        },
      },
      latency: {
        library: (import 'sli-value-libraries/latency-histogram-quantile-using-bucket-metric-percentile-and-secs-target.libsonnet'),
        description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          bucket: 'bucket',
          sum: 'sum',
          count: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability', 'httpRequestsLatency'],
      targetMetrics: {
        requestCount: 'count',
        requestBucket: 'bucket',
      },
    },
  },
  nodejs_http_request_duration_seconds: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
        resource: 'path',
        errorStatus: 'status_code',
      },
      metrics: {
        count: 'http_request_duration_seconds_count',
        sum: 'http_request_duration_seconds_sum',
        bucket: 'http_request_duration_seconds_bucket',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-counter-using-single-metric-for-both-num-and-dem-filtered-by-status-label.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'count',
        },
      },
      latency: {
        library: (import 'sli-value-libraries/latency-histogram-quantile-using-bucket-metric-percentile-and-secs-target.libsonnet'),
        description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          bucket: 'bucket',
          sum: 'sum',
          count: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability', 'httpRequestsLatency'],
      targetMetrics: {
        requestCount: 'count',
        requestBucket: 'bucket',
      },
    },
  },
  grafana_http_request_duration_seconds: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
        resource: 'handler',
        errorStatus: 'status_code',
      },
      metrics: {
        count: 'grafana_http_request_duration_seconds_count',
        sum: 'grafana_http_request_duration_seconds_sum',
        bucket: 'grafana_http_request_duration_seconds_bucket',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-counter-using-single-metric-for-both-num-and-dem-filtered-by-status-label.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'count',
        },
      },
      latency: {
        library: (import 'sli-value-libraries/latency-histogram-quantile-using-bucket-metric-percentile-and-secs-target.libsonnet'),
        description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          bucket: 'bucket',
          sum: 'sum',
          count: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability', 'httpRequestsLatency'],
      targetMetrics: {
        requestCount: 'count',
        requestBucket: 'bucket',
      },
    },
  },
  http_requests_total: {
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
        library: (import 'sli-value-libraries/availability-counter-using-single-metric-for-both-num-and-dem-filtered-by-status-label.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability'],
      targetMetrics: {
        requestCount: 'count',
      },
    },
  },
  http_request_duration_seconds: {
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
        library: (import 'sli-value-libraries/latency-histogram-quantile-using-bucket-metric-percentile-and-secs-target.libsonnet'),
        description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          bucket: 'bucket',
          sum: 'sum',
          count: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['resource'],
      elements: ['httpRequestsLatency'],
      targetMetrics: {
        requestBucket: 'bucket',
      },
    },
  },
  nginx_ingress_controller_requests: {
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
        library: (import 'sli-value-libraries/availability-counter-using-single-metric-for-both-num-and-dem-filtered-by-status-label.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['errorStatus'],
      elements: ['httpRequestsAvailability'],
      targetMetrics: {
        requestCount: 'count',
      },
    },
  },
  nginx_ingress_controller_request_duration_seconds: {
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
        library: (import 'sli-value-libraries/availability-counter-using-single-metric-for-both-num-and-dem-filtered-by-status-label.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'count',
        },
      },
      latency: {
        library: (import 'sli-value-libraries/latency-histogram-quantile-using-bucket-metric-percentile-and-secs-target.libsonnet'),
        description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          bucket: 'bucket',
          sum: 'sum',
          count: 'count',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: ['errorStatus'],
      elements: ['httpRequestsAvailability', 'httpRequestsLatency'],
      targetMetrics: {
        requestCount: 'count',
        requestBucket: 'bucket',
      },
    },
  },
  aws_alb: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'Environment',
        product: 'job',
      },
      metrics: {
        count4xx: 'aws_alb_httpcode_target_4_xx_count_sum',
        count5xx: 'aws_alb_httpcode_target_5_xx_count_sum',
        requestCount: 'aws_alb_request_count_sum',
        responseTimeAverage: 'aws_alb_target_response_time_average',
        responseTimeP90: 'aws_alb_target_response_time_p90',
        responseTimeP95: 'aws_alb_target_response_time_p95',
        responseTimeP99: 'aws_alb_target_response_time_p99',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-counter-using-2-failure-metrics-for-num-and-1-total-metric-for-dem.libsonnet'),
        description: 'The error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          code4xx: 'count4xx',
          code5xx: 'count5xx',
          codeAll: 'requestCount',
        },
      },
      latency: {
        library: (import 'sli-value-libraries/latency-gauge-using-max-of-cloudwatch-percentile-metric.libsonnet'),
        description: 'Target latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
        targetMetrics: {
          p90: 'responseTimeP90',
          p95: 'responseTimeP95',
          p99: 'responseTimeP99',
          average: 'responseTimeAverage',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_sqs: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'Environment',
        product: 'job',
      },
      metrics: {
        messagesVisible: 'aws_sqs_approximate_number_of_messages_visible_average',
        oldestMessage: 'aws_sqs_approximate_age_of_oldest_message_maximum',
        messagesSent: 'aws_sqs_number_of_messages_sent_sum',
        messagesDeleted: 'aws_sqs_number_of_messages_deleted_sum',
      },
      customSelectorLabels: {
        deadletterQueueName: 'dimension_QueueName',
      },
      customSelectors: {
        deadletterQueueName: '.+dlq.+',
      },
    },
    sliTypesConfig: {
      freshness: {
        library: (import 'sli-value-libraries/freshness-gauge-for-queues-using-single-metric-and-secs-target.libsonnet'),
        description: 'Age of oldest message in SQS queue should be less than %(metricTarget)s seconds for %(sliDescription)s',
        targetMetrics: {
          oldestMessage: 'oldestMessage',
          deletedMessages: 'messagesDeleted',
        },
      },
      correctness: {
        library: (import 'sli-value-libraries/correctness-gauge-for-queues-using-standard-and-dead-letter-queue-metrics.libsonnet'),
        description: 'There should be no messages in the DLQ for %(sliDescription)s',
        targetMetrics: {
          visibleMessages: 'messagesVisible',
          oldestMessage: 'oldestMessage',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: ['cloudwatchSqs'],
      targetMetrics: {
        oldestMessage: 'oldestMessage',
        sentMessages: 'messagesSent',
        visibleMessages: 'messagesVisible',
        deletedMessages: 'messagesDeleted',
      },
    },
  },
  thanos_compact_group_compactions: {
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
        library: (import 'sli-value-libraries/availability-counter-using-1-failure-metric-for-num-and-1-total-metric-for-dem.libsonnet'),
        description: 'The rate of %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          failure: 'totalFailures',
          successAndFailure: 'total',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  up: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        duration: 'up',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-gauge-using-single-metric-for-both-num-and-dem.libsonnet'),
        description: 'The average of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'duration',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  scrape_duration_seconds: {
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
        library: (import 'sli-value-libraries/availability-gauge-using-single-metric-for-both-num-and-dem.libsonnet'),
        description: 'The average of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'duration',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_rds_read: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'Environment',
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
        library: (import 'sli-value-libraries/latency-gauge-using-secs-metric-and-secs-target.libsonnet'),
        description: 'The average latency of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageLatency',
        },
      },
      iops: {
        library: (import 'sli-value-libraries/availability-gauge-using-single-metric-for-both-num-and-dem.libsonnet'),
        description: 'The average IOPS of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageIops',
        },
      },
      throughput: {
        library: (import 'sli-value-libraries/availability-gauge-using-single-metric-for-both-num-and-dem.libsonnet'),
        description: 'The average throughput of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageThroughput',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_rds_write: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'Environment',
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
        library: (import 'sli-value-libraries/latency-gauge-using-secs-metric-and-secs-target.libsonnet'),
        description: 'The average latency of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageLatency',
        },
      },
      iops: {
        library: (import 'sli-value-libraries/availability-gauge-using-single-metric-for-both-num-and-dem.libsonnet'),
        description: 'The average IOPS of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageIops',
        },
      },
      throughput: {
        library: (import 'sli-value-libraries/availability-gauge-using-single-metric-for-both-num-and-dem.libsonnet'),
        description: 'The average throughput of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageThroughput',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_s3: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        averageLatency: 'aws_s3_total_request_latency_average',
        sum4xx: 'aws_s3_4xx_errors_sum',
        sum5xx: 'aws_s3_5xx_errors_sum',
        requestsSum: 'aws_s3_all_requests_sum',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-counter-using-2-failure-metrics-for-num-and-1-total-metric-for-dem.libsonnet'),
        description: 'The error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          code4xx: 'sum4xx',
          code5xx: 'sum5xx',
          codeAll: 'requestsSum',
        },
      },
      latency: {
        library: (import 'sli-value-libraries/latency-gauge-using-secs-metric-and-secs-target.libsonnet'),
        description: 'The average latency of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageLatency',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_es: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'Environment',
        product: 'job',
      },
      metrics: {
        averageLatency: 'aws_es_search_latency_average',
        sum4xx: 'aws_es_4xx_sum',
        sum5xx: 'aws_es_5xx_sum',
        requestsSum: 'aws_es_elasticsearch_requests_sum',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-counter-using-2-failure-metrics-for-num-and-1-total-metric-for-dem.libsonnet'),
        description: 'The error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          code4xx: 'sum4xx',
          code5xx: 'sum5xx',
          codeAll: 'requestsSum',
        },
      },
      latency: {
        library: (import 'sli-value-libraries/latency-gauge-using-secs-metric-and-secs-target.libsonnet'),
        description: 'The average latency of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageLatency',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  gitlab_test: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
      },
      metrics: {
        totalSuccess: 'gitlab_test_metric_success',
        total: 'gitlab_test_metric_total',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-counter-using-1-success-metric-for-num-and-1-total-metric-for-dem.libsonnet'),
        description: 'The rate of %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          success: 'totalSuccess',
          successAndFailure: 'total',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_workspaces_availability: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'environment',
        product: 'job',
        resource: 'dimension_DirectoryId',
      },
      metrics: {
        failure1: 'aws_work_spaces_unhealthy_sum',
        failure2: 'aws_work_spaces_maintenance_sum',
        success: 'aws_work_spaces_available_sum',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-gauge-using-2-failure-metrics-for-num-and-3-metrics-dem.libsonnet'),
        description: 'The average of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          failure1: 'failure1',
          failure2: 'failure2',
          success: 'success',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_workspaces_connection_attempts: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'environment',
        product: 'job',
        resource: 'dimension_DirectoryId',
      },
      metrics: {
        failure: 'aws_work_spaces_connection_failure_sum',
        total: 'aws_work_spaces_connection_attempt_sum',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-gauge-using-1-failure-metric-for-num-and-1-total-metric-for-dem.libsonnet'),
        description: 'The average of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          failure: 'failure',
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
  aws_cwagent: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'environment',
        product: 'job',
      },
      metrics: {
        averageSaturation: 'aws_cw_agent_mem_used_percent_average',
      },
    },
    sliTypesConfig: {
      saturation: {
        library: (import 'sli-value-libraries/saturation-gauge-with-useage-metric-and-percent-target.libsonnet'),
        description: 'The average saturation of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
        targetMetrics: {
          target: 'averageSaturation',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_ec2_status_check: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'environment',
        product: 'job',
      },
      metrics: {
        averageStatus: 'aws_ec2_status_check_failed_sum',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-gauge-with-status-metric-and-integer-target.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'averageStatus',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_autoscaling_group_in_service_instance: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'environment',
        product: 'job',
      },
      metrics: {
        desired: 'aws_autoscaling_group_desired_capacity_average',
        inservice: 'aws_autoscaling_group_in_service_instance_average',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-gauge-using-inservice-and-desired-instance-metrics.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          desired: 'desired',
          inservice: 'inservice',
        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  template: {
    metricTypeConfig: {
      selectorLabels: {
        environment: '',
        product: '',
      },
      metrics: {

      },
    },
    sliTypesConfig: {
      sliType: {
        library: '',
        description: '',
        targetMetrics: {

        },
      },
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
      targetMetrics: {},
    },
  },
  aws_cwsynthetics_success_check: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'environment',
        product: 'job',
      },
      metrics: {
        averageSuccess: 'aws_cloudwatchsynthetics_success_percent_average',
      },
    },
    sliTypesConfig: {
      availability: {
        library: (import 'sli-value-libraries/availability-gauge-with-success-metric-and-integer-target.libsonnet'),
        description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'averageSuccess',
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

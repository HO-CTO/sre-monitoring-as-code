// This file is for storing the config of the MaC framework

// Config items
// The different categories of metrics and their config
local metricCategories = {
  'http_server_requests_seconds': {
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
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability', 'httpRequestsLatency'],
    },
  },
  'grafana_http_request_duration_seconds': {
    selectorLabels: {
      environment: 'namespace',
      product: 'job',
      resource: 'handler',
      errorStatus: 'status_code',
    },
    metrics: {
      count: 'grafana_http_request_duration_seconds_count',
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability'],
    },
  },
  'http_requests_total': {
    selectorLabels: {
      environment: 'namespace',
      product: 'job',
      resource: 'handler',
      errorStatus: 'code',
    },
    metrics: {
      count: 'http_requests_total',
    },
    detailDashboardConfig: {
      standardTemplates: ['resource', 'errorStatus'],
      elements: ['httpRequestsAvailability'],
    },
  },
  'http_request_duration_seconds': {
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
    detailDashboardConfig: {
      standardTemplates: ['resource'],
      elements: ['httpRequestsLatency'],
    },
  },
  'nginx_ingress_controller_requests': {
    selectorLabels: {
      environment: 'exported_namespace',
      product: 'exported_service',
      errorStatus: 'status',
    },
    metrics: {
      count: 'nginx_ingress_controller_requests',
    },
    detailDashboardConfig: {
      standardTemplates: ['errorStatus'],
      elements: ['httpRequestsAvailability'],
    },
  },
  'nginx_ingress_controller_request_duration_seconds': {
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
    detailDashboardConfig: {
      standardTemplates: ['errorStatus'],
      elements: ['httpRequestsAvailability', 'httpRequestsLatency'],
    },
  },
  'aws_alb': {
    selectorLabels: {
      environment: 'namespace',
      product: 'job',
      resource: '',
    },
    metrics: {
      count4xx: 'aws_alb_httpcode_target_4_xx_count_sum',
      count5xx: 'aws_alb_httpcode_target_5_xx_count_sum',
      requestCount: 'aws_alb_request_count_sum',
      responseTime: 'aws_alb_target_response_time',
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
    },
  },
  'aws_sqs': {
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
      queueName: 'queue_name',
      queueType: 'queue_type',
      targetQueue: 'dimension_QueueName',
    },
    customSelectors: {
      queueName: '.+dlq.+',
      queueType: 'deadletter',
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: ['cloudwatchSqs'],
    },
  },
  'thanos_compact_group_compactions': {
    selectorLabels: {
      environment: 'namespace',
      product: 'job',
    },
    metrics: {
      totalFailures: 'thanos_compact_group_compactions_failures_total',
      total: 'thanos_compact_group_compactions_total',
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
    },
  },
  'up': {
    selectorLabels: {
      environment: 'namespace',
    },
    metrics: {
      duration: 'up',
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
    },
  },
  'scrape_duration_seconds': {
    selectorLabels: {
      environment: 'namespace',
      product: 'job',
    },
    metrics: {
      duration: 'scrape_duration_seconds',
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
    },
  },
  'aws_rds_read': {
    selectorLabels: {
      environment: 'namespace',
      product: 'job',
    },
    metrics: {
      averageLatency: 'aws_rds_read_latency_average',
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
    },
  },
  'aws_rds_write': {
    selectorLabels: {
      environment: 'namespace',
      product: 'job',
    },
    metrics: {
      averageLatency: 'aws_rds_write_latency_average',
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
    },
  },
  'aws_es': {
    selectorLabels: {
      environment: 'namespace',
      product: 'job',
    },
    metrics: {
      averageLatency: 'aws_es_search_latency_average',
    },
    detailDashboardConfig: {
      standardTemplates: [],
      elements: [],
    },
  },
};

// Collection of imports and config for each SLI type
local sliMetricLibs = {
  'http-errors': {
    library: (import 'sli-metric-libraries/sli-availability-promclient.libsonnet'),
    metricTypes: {
      'http_server_requests_seconds_count': metricCategories['http_server_requests_seconds'],
      'grafana_http_request_duration_seconds_count': metricCategories['grafana_http_request_duration_seconds'],
      'http_requests_total': metricCategories['http_requests_total'],
      'nginx_ingress_controller_requests': metricCategories['nginx_ingress_controller_requests'],
    },
    description: 'Error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
    category: 'Availability',
  },
  'http-latency': {
    library: (import 'sli-metric-libraries/sli-latency-promclient.libsonnet'),
    metricTypes: {
      'http_request_duration_seconds_bucket': metricCategories['http_request_duration_seconds'],
      'http_server_requests_seconds_bucket': metricCategories['http_server_requests_seconds'],
      'nginx_ingress_controller_request_duration_seconds_bucket': metricCategories['nginx_ingress_controller_request_duration_seconds'],
    },
    description: 'Request latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
    category: 'Latency',
  },
  'alb-target-group-http-errors': {
    library: (import 'sli-metric-libraries/sli-availability-cloudwatch-alb.libsonnet'),
    metricTypes: {
      'aws_alb_request_count_sum': metricCategories['aws_alb'],
    },
    description: 'the error rate for %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
    category: 'Availability',
  },
  'alb-target-group-latency': {
    library: (import 'sli-metric-libraries/sli-latency-cloudwatch-alb.libsonnet'),
    metricTypes: {
      'aws_alb_target_response_time': metricCategories['aws_alb'],
    },
    description: 'Target latency for %(sliDescription)s should be below %(metricTarget)0.1fs for the %(latencyPercentile)0.0fth percentile',
    category: 'Latency',
  },
  'sqs-high-latency-in-queue': {
    library: (import 'sli-metric-libraries/sli-freshness-cloudwatch-sqs.libsonnet'),
    metricTypes: {
      'aws_sqs_approximate_age_of_oldest_message_sum': metricCategories['aws_sqs'],
    },
    description: 'Age of oldest message in SQS queue should be less than %(metricTarget)s seconds for %(sliDescription)s',
    category: 'Pipeline Freshness',
  },
  'sqs-message-received-in-dlq': {
    library: (import 'sli-metric-libraries/sli-correctness-cloudwatch-sqs-dlq.libsonnet'),
    metricTypes: {
      'aws_sqs_approximate_number_of_messages_visible_sum': metricCategories['aws_sqs'],
    },
    description: 'there should be no messages in the DLQ for %(sliDescription)s',
    category: 'Pipeline Correctness',
  },
  'generic-error': {
    library: (import 'sli-metric-libraries/sli-availability-generic.libsonnet'),
    metricTypes: {
      'thanos_compact_group_compactions_total': metricCategories['thanos_compact_group_compactions'],
    },
    description: 'the rate of %(sliDescription)s should be below %(metric_target_percent)0.1f%%',
    category: 'Availability',
  },
  'generic_avgovertimem': {
    library: (import 'sli-metric-libraries/sli-avgovertime-generic.libsonnet'),
    metricTypes: {
      'up': metricCategories['up'],
      'scrape_duration_seconds': metricCategories['scrape_duration_seconds'],
    },
    description: 'the average of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
    category: 'Availability',
  },
  'average_latency': {
    library: (import 'sli-metric-libraries/sli-average-metric.libsonnet'),
    metricTypes: {
      'aws_rds_read_latency_average': metricCategories['aws_rds_read'],
      'aws_rds_write_latency_average': metricCategories['aws_rds_write'],
      'aws_es_search_latency_average': metricCategories['aws_es'],
    },
    targetMetric: 'averageLatency',
    description: 'The average latency of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
    category: 'Latency',
  },
};

// Collection of imports for detail dashboard elements
local detailDashboardElements = {
  httpRequestsAvailability: (import 'dashboards/detail-dashboard-elements/http-requests-availability.libsonnet'),
  httpRequestsLatency: (import 'dashboards/detail-dashboard-elements/http-requests-latency.libsonnet'),
  cloudwatchSqs: (import 'dashboards/detail-dashboard-elements/cloudwatch-sqs.libsonnet'),
};

// The list of error budget burn rate windows used for alerts
local burnRateWindowList = [
  { severity: '1', 'for': '2m', long: '1h', short: '5m', factor: 14.4 },
  { severity: '2', 'for': '2m', long: '6h', short: '30m', factor: 6 },
  { severity: '4', 'for': '3h', long: '3d', short: '6h', factor: 1 },
];

// The template for error budget burn rule names
local burnRateRuleNameTemplate = 'slo_burnrate:%s';

// The localhost urls for alerts
local localhostUrls = {
  grafana: 'localhost:3000',
  alertmanager: 'localhost:9093',
};

// File exports
{
  metricCategories: metricCategories,
  sliMetricLibs: sliMetricLibs,
  detailDashboardElements: detailDashboardElements,
  burnRateWindowList: burnRateWindowList,
  burnRateRuleNameTemplate: burnRateRuleNameTemplate,
  localhostUrls: localhostUrls,
}

// This file is for storing the config of the MaC framework

// Config items
{
  // Collection of imports for SLI metric library files for each SLI type
  sliMetricLibs: {
    'http-errors': {
      library: (import 'sli-metric-libraries/sli-availability-promclient.libsonnet'),
      metricTypes: {
        'http_server_requests_seconds_count': {
          selectorLabels: {
            environment: 'namespace',
            product: 'job',
            resource: 'uri',
            errorStatus: 'status',
          },
          metrics: {
            count: 'http_server_requests_seconds_count',
          },
          outboundSelectorLabels: {
            environment: 'namespace',
            product: 'job',
            resource: 'uri',
            errorStatus: 'status',
          },
          outboundMetrics: {
            count: 'http_client_requests_seconds_count',
          },
        },
        'grafana_http_request_duration_seconds_count': {
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
        },
      },
      detailDashboardConfig: {
        standardTemplates: ['resource', 'errorStatus'],
        elements: ['httpRequestsAvailability'],
      },
    },
    'http-latency': {
      library: (import 'sli-metric-libraries/sli-latency-promclient.libsonnet'),
      metricTypes: {
        'http_request_duration_seconds_bucket': {
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
        'http_server_requests_seconds_bucket': {
          selectorLabels: {
            environment: 'namespace',
            product: 'job',
            resource: 'uri',
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
          },
          outboundMetrics: {
            bucket: 'http_client_requests_seconds_bucket',
          },
        },
        'nginx_ingress_controller_request_duration_seconds_bucket': {
          selectorLabels: {
            environment: 'exported_namespace',
            product: 'exported_service',
          },
          metrics: {
            sum: 'nginx_ingress_controller_request_duration_seconds_sum',
            count: 'nginx_ingress_controller_request_duration_seconds_count',
            bucket: 'nginx_ingress_controller_request_duration_seconds_bucket',
          },
        },
      },
      detailDashboardConfig: {
        standardTemplates: ['resource'],
        elements: ['httpRequestsLatency'],
      },
    },
    'alb-target-group-http-errors': {
      library: (import 'sli-metric-libraries/sli-availability-cloudwatch-alb.libsonnet'),
      metricTypes: {
        'aws_alb_request_count_sum': {
          selectorLabels: {
            environment: 'namespace',
            product: 'job',
            resource: '',
          },
          metrics: {
            count4xx: 'aws_alb_httpcode_target_4_xx_count_sum',
            count5xx: 'aws_alb_httpcode_target_5_xx_count_sum',
            requestCount: 'aws_alb_request_count_sum',
          },
        },
      },
      detailDashboardConfig: {
        standardTemplates: [],
        elements: [],
      },
    },
    'alb-target-group-latency': {
      library: (import 'sli-metric-libraries/sli-latency-cloudwatch-alb.libsonnet'),
      metricTypes: {
        'aws_alb_target_response_time': {
          selectorLabels: {
            environment: 'namespace',
            product: 'job',
            resource: '',
          },
          metrics: {
            responseTime: 'aws_alb_target_response_time',
          },
        },
      },
      detailDashboardConfig: {
        standardTemplates: [],
        elements: [],
      },
    },
    'sqs-high-latency-in-queue': {
      library: (import 'sli-metric-libraries/sli-freshness-cloudwatch-sqs.libsonnet'),
      metricTypes: {
        'aws_sqs_approximate_age_of_oldest_message_sum': {
          selectorLabels: {
            environment: 'namespace',
            product: 'job',
          },
          metrics: {
            oldestMessage: 'aws_sqs_approximate_age_of_oldest_message_sum',
            messagesDeleted: 'aws_sqs_number_of_messages_deleted_sum',
          },
          customSelectorLabels: {
            queueType: 'queue_type',
            targetQueue: 'dimension_QueueName',
          },
          customSelectors: {
            queueType: 'deadletter',
          },
          // standardQueueSelector: 'queue_type!~"deadletter|"',
          // deadletterQueueSelector: 'queue_type=~"deadletter|"',
          // targetLabel: 'dimension_QueueName',
        },
      },
      detailDashboardConfig: {
        standardTemplates: [],
        elements: ['cloudwatchSqs'],
      },
    },
    'sqs-message-received-in-dlq': {
      library: (import 'sli-metric-libraries/sli-correctness-cloudwatch-sqs-dlq.libsonnet'),
      metricTypes: {
        'aws_sqs_approximate_number_of_messages_visible_sum': {
          selectorLabels: {
            environment: 'namespace',
            product: 'job',
          },
          metrics: {
            messagesVisible: 'aws_sqs_approximate_number_of_messages_visible_sum',
            oldestMessage: 'aws_sqs_approximate_age_of_oldest_message_sum',
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
          // deadletterQueueNameSelector: 'queue_name=~".+dlq.+"',
          // standardQueueSelector: 'queue_type!~"deadletter|"',
          // deadletterQueueSelector: 'queue_type=~"deadletter|"',
          // targetLabel: 'dimension_QueueName',
        },
      },
      detailDashboardConfig: {
        standardTemplates: [],
        elements: ['cloudwatchSqs'],
      },
    },
    'generic-error': {
      library: (import 'sli-metric-libraries/sli-availability-generic.libsonnet'),
      metricTypes: {
        'thanos_compact_group_compactions_total': {
          selectorLabels: {
            environment: 'namespace',
            product: 'job',
          },
          metrics: {
            totalFailures: 'thanos_compact_group_compactions_failures_total',
            total: 'thanos_compact_group_compactions_total',
          },
        },
      },
      detailDashboardConfig: {
        standardTemplates: [],
        elements: [],
      },
    },
    'generic_avgovertimem': {
      library: (import 'sli-metric-libraries/sli-avgovertime-generic.libsonnet'),
      metricTypes: {
        'up': {
          selectorLabels: {
            environment: 'namespace',
          },
          metrics: {
            duration: 'up',
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
        },
      },
      detailDashboardConfig: {
        standardTemplates: [],
        elements: [],
      },
    },
  },
  // The list of error budget burn rate windows used for alerts
  burnRateWindowList: [
    { severity: '1', 'for': '2m', long: '1h', short: '5m', factor: 14.4 },
    { severity: '2', 'for': '2m', long: '6h', short: '30m', factor: 6 },
    { severity: '4', 'for': '3h', long: '3d', short: '6h', factor: 1 },
  ],
  // The template for error budget burn rule names
  burnRateRuleNameTemplate: 'slo_burnrate:%s',
  // The localhost urls for alerts
  localhostUrls: {
    grafana: 'localhost:3000',
    alertmanager: 'localhost:9093',
  },
}

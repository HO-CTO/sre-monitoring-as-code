// Library to generate Grafana and Prometheus config for Cloudwatch SQS correctness

// MaC imports
local sliMetricLibraryFunctions = import '../util/sli-metric-library-functions.libsonnet';
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local row = grafana.row;
local template = grafana.template;
local statPanel = grafana.statPanel;

// Creates Grafana dashboard graph panel for an SLI type
// @param sliSpec The spec for the SLI having its dashboard created
// @returns Grafana graph panel object
local createGraphPanel(sliSpec) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local dashboardSelectors = sliMetricLibraryFunctions.createDashboardSelectors(metricConfig, sliSpec);

  graphPanel.new(
    title = '%s' % sliSpec.sliDescription,
    description = |||
      * Sample interval is %(evalInterval)s 
      * Resource selectors are %(selectors)s
      * Only queues with type deadletter
    ||| % {
      evalInterval: sliSpec.evalInterval,
      selectors: std.strReplace(std.join(', ', sliMetricLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
    },
    datasource = 'prometheus',
    min = 0,
    fill = 0,
  ).addTarget(
    prometheus.target(
      'sum(avg_over_time(%(messagesVisibleMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]) or vector(0))' % {
        messagesVisibleMetric: metricConfig.metrics.messagesVisible,
        selectors: std.join(',', dashboardSelectors),
        queueSelector: metricConfig.deadletterQueueNameSelector,
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat = 'avg number of msgs visible in dlq',
    )
  ).addTarget(
    prometheus.target(
      'sum(avg_over_time(sqs_message_received_in_dlq_avg{%(dashboardSliLabelSelectors)s}[%(evalInterval)s]) 
        or vector(0))/ sum(count_over_time(%(messagesVisibleMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]) 
        or vector(0))' % {
          messagesVisibleMetric: metricConfig.metrics.messagesVisible,
          selectors: std.join(',', dashboardSelectors),
          queueSelector: metricConfig.deadletterQueueNameSelector,
          dashboardSliLabelSelectors: sliSpec.dashboardSliLabelSelectors,
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat = 'avg period where msgs in dlq >= 1',
    )
  ).addTarget(
    prometheus.target(
      'sum(avg_over_time(%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s}
        [%(evalInterval)s]) or vector(0))' % {
          oldestMessageMetric: metricConfig.metrics.oldestMessage,
          selectors: std.join(',', dashboardSelectors),
          queueSelector: metricConfig.deadletterQueueNameSelector,
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat = 'avg age of oldest msg in dlq (secs)',
    )
  ).addSeriesOverride(
    {
      alias: '/avg age of oldest msg in dlq/',
      yaxis: 2,
      color: '#8AB8FF',
    },
  ).addSeriesOverride(
    {
      alias: '/avg period where msgs in dlq >= 1/',
      color: 'red',
    },
  ).addSeriesOverride(
    {
      alias: '/avg number of msgs visible in dlq/',
      color: 'orange',
    },
  );

// Creates custom recording rules for an SLI type
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @returns JSON defining the recording rules
local createCustomRecordingRules(sliSpec, sliMetadata, config) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliMetricLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);

  [
    {
      record: 'sli_value',
      expr: |||
        (sum(avg_over_time(sqs_message_received_in_dlq_avg{%(ruleSliLabelSelectors)s}[%(evalInterval)s])) or vector(0))
        /
        (sum(count_over_time(%(messagesVisibleMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s])) or vector(0))
      ||| % {
        messagesVisibleMetric: metricConfig.metrics.messagesVisible,
        selectors: std.join(',', ruleSelectors),
        queueSelector: metricConfig.deadletterQueueNameSelector,
        ruleSliLabelSelectors: sliSpec.ruleSliLabelSelectors,
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
    {
      // unsure how to add to this expression
      record: 'sqs_message_received_in_dlq_avg',
      expr: |||
        (%(messagesVisibleMetric)s{%(selectors)s, %(queueSelector)s} >= bool 1) or vector(0)
      ||| % {
        messagesVisibleMetric: metricConfig.metrics.messagesVisible,
        selectors: std.join(',', ruleSelectors),
        queueSelector: metricConfig.deadletterQueueNameSelector,
      },
      labels: sliSpec.sliLabels,
    },
  ];

// Creates additional detail dashboard templates for this SLI type
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana template objects
local createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction) =
  [
    template.new(
      name = '%s_%s_%s' % [direction, type, selectorLabel],
      label = stringFormattingFunctions.capitaliseFirstLetters('%s %s %s' % [direction, type, selectorLabel]),
      datasource = 'prometheus',
      query = 'label_values({__name__=~"%(oldestMessageMetrics)s", %(environmentSelectors)s, %(productSelectors)s, %(queueSelectors)s}, %(selectorLabel)s)' % {
        oldestMessageMetrics: std.join('|', metrics[direction][sliType].oldestMessage),
        environmentSelectors: selectors[direction].environment,
        productSelectors: selectors[direction].product,
        queueSelectors: std.join(', ', otherConfig['%sQueueSelector' % type]),
        selectorLabel: selectorLabel,
      },
      current = 'all',
      includeAll = true,
      multi = true,
      refresh = 'time',
    )
    for type in ['standard', 'deadletter']
    for selectorLabel in otherConfig.targetLabel
  ];

// Creates detail dashboard panels for this SLI type
// @param sliType The type of SLI
// @param metrics Collection of metrics used for each SLI type in dashboard
// @param selectorLabels List of labels used by selectors
// @param selectors List of selectors
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana panel objects
local createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction) =
  std.flattenArrays([
    [row.new(
      title = stringFormattingFunctions.capitaliseFirstLetters('%s Cloudwatch SQS' % direction),
    ) + { gridPos: { w: 24, h: 1 } }],
    [statPanel.new(
      // SQS messages age of oldest message in DLQ queues
      title = 'SQS - Approx age of oldest message in Dead Letter Queues',
      datasource = 'prometheus',
      unit = 's',
      justifyMode = 'center',
    ).addTarget(
      prometheus.target(|||
          sum by (dimension_QueueName) (aws_sqs_approximate_age_of_oldest_message_sum{queue_type="deadletter",dimension_QueueName=~"$inbound_deadletter_dimension_QueueName"})
        |||, 
        legendFormat = '{{dimension_QueueName}}')
    ) + { options+: { textMode: 'value_and_name' } } + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages visible in DLQs
      title = 'SQS - Messages visible in Dead Letter Queues',
      datasource = 'prometheus',
      min = 0,
    ).addTarget(
      prometheus.target(|||
          sum by (dimension_QueueName) (aws_sqs_approximate_number_of_messages_visible_sum{queue_type="deadletter",dimension_QueueName=~"$inbound_deadletter_dimension_QueueName"})
        |||,
        legendFormat = '{{dimension_QueueName}}')
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
    [statPanel.new(
      // SQS messages age of oldest message in standard queues
      title = 'SQS - Approx age of oldest message in standard queues',
      datasource = 'prometheus',
      unit = 's',
      justifyMode = 'center',
    ).addTarget(
      prometheus.target(|||
          sum by (dimension_QueueName) (aws_sqs_approximate_age_of_oldest_message_sum{queue_type!~"deadletter",dimension_QueueName=~"$inbound_standard_dimension_QueueName"})
        |||,
        legendFormat = '{{dimension_QueueName}}')
    ) + { options+: { textMode: 'value_and_name' } } + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages visible in standard queues
      title = 'SQS - Messages visible in standard queues',
      datasource = 'prometheus',
      min = 0,
    ).addTarget(
      prometheus.target(|||
          sum by (dimension_QueueName) (aws_sqs_approximate_number_of_messages_visible_sum{queue_type!~"deadletter",dimension_QueueName=~"$inbound_standard_dimension_QueueName"})
        |||,
        legendFormat = '{{dimension_QueueName}}')
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
    [graphPanel.new(
      // SQS messages sent - standard queues
      title = 'SQS - Messages sent (standard queues)',
      datasource = 'prometheus',
      min = 0,
    ).addTarget(
      prometheus.target(|||
          sum by (dimension_QueueName) (aws_sqs_number_of_messages_sent_sum{queue_type!~"deadletter",dimension_QueueName=~"$inbound_standard_dimension_QueueName"})
        |||, 
        legendFormat = '{{dimension_QueueName}}')
    ) + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages deleted - in standard queues
      title = 'SQS - Messages deleted (standard queues)',
      datasource = 'prometheus',
      min = 0,
    ).addTarget(
      prometheus.target(|||
          sum by (dimension_QueueName) (aws_sqs_number_of_messages_deleted_sum{queue_type!~"deadletter",dimension_QueueName=~"$inbound_standard_dimension_QueueName"})
        |||,
        legendFormat = '{{dimension_QueueName}}')
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
  ]);

// File exports
{
  description: 'there should be no messages in the DLQ for %(sliDescription)s',
  category: 'Pipeline Correctness',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction): createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction),
}

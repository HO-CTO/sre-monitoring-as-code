// Library to generate Grafana and Prometheus config for Cloudwatch SQS correctness

// MaC imports
local sliMetricLibraryFunctions = import '../util/sli-metric-library-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;

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
        queueSelector: metricConfig.queueSelector,
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
          queueSelector: metricConfig.queueSelector,
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
          queueSelector: metricConfig.queueSelector,
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
        queueSelector: metricConfig.queueSelector,
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
        queueSelector: metricConfig.queueSelector,
      },
      labels: sliSpec.sliLabels,
    },
  ];

// Creates additional detail dashboard templates for this SLI type
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana template objects
local createDetailDashboardTemplates(direction) =
  [

  ];

// Creates detail dashboard panels for this SLI type
// @param sliType The type of SLI
// @param metrics Collection of metrics used for each SLI type in dashboard
// @param selectorLabels List of labels used by selectors
// @param selectors List of selectors
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana panel objects
local createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction) =
  std.flattenArrays([
    
  ]);

// File exports
{
  description: 'there should be no messages in the DLQ for %(sliDescription)s',
  category: 'Pipeline Correctness',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(direction): createDetailDashboardTemplates(direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction),
}

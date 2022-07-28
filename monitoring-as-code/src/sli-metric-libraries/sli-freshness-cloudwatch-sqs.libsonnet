// Library to generate Grafana and Prometheus config for Cloudwatch SQS latency

// MaC imports
local sliMetricLibraryFunctions = import '../util/sli-metric-library-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local row = grafana.row;
local template = grafana.template;

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
      * Only queues where type is not deadletter
    ||| % {
      evalInterval: sliSpec.evalInterval,
      selectors: std.strReplace(std.join(', ', sliMetricLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
    },
    datasource = 'prometheus',
    min = 0,
    fill = 0,
  ).addTarget(
    prometheus.target(
      'sum(avg_over_time(%(messagesDeletedMetric)s{%(selectors)s, %(queueSelector)s}
        [%(evalInterval)s]) or vector(0))' % {
          messagesDeletedMetric: metricConfig.metrics.messagesDeleted,
          selectors: std.join(',', dashboardSelectors),
          queueSelector: metricConfig.standardQueueSelector,
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat='avg number of msgs delivered',
    )
  ).addTarget(
    prometheus.target(
      'sum(avg_over_time(sqs_high_latency_in_queue_avg{%(dashboardSliLabelSelectors)s}[%(evalInterval)s]) 
        or vector(0))/ sum(count_over_time(%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s}
        [%(evalInterval)s]) or vector(0))' % {
          oldestMessageMetric: metricConfig.metrics.oldestMessage,
          selectors: std.join(',', dashboardSelectors),
          queueSelector: metricConfig.standardQueueSelector,
          dashboardSliLabelSelectors: sliSpec.dashboardSliLabelSelectors,
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat='avg period where msg in standard queue > %s seconds' % sliSpec.metricTarget,
    )
  ).addTarget(
    prometheus.target(
      'sum(avg_over_time(%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]) or vector(0))' % {
        oldestMessageMetric: metricConfig.metrics.oldestMessage,
        selectors: std.join(',', dashboardSelectors),
        queueSelector: metricConfig.standardQueueSelector,
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg age of oldest msg in standard queue (secs)',
    )
  ).addSeriesOverride(
    {
      alias: '/avg age of oldest msg in standard queue/',
      yaxis: 2,
      color: 'orange',
    },
  ).addSeriesOverride(
    {
      alias: '/avg period where msg in standard queue > %s seconds/' % sliSpec.metricTarget,
      color: 'red',
    },
  ).addSeriesOverride(
    {
      alias: '/avg number of msgs delivered/',
      color: 'green',
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
        (sum(avg_over_time(sqs_high_latency_in_queue_avg{%(ruleSliLabelSelectors)s}[%(evalInterval)s])) or vector(0))
        /
        (sum(count_over_time(%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s])) or vector(0))
      ||| % {
        oldestMessageMetric: metricConfig.metrics.oldestMessage,
        selectors: std.join(',', ruleSelectors),
        queueSelector: metricConfig.standardQueueSelector,
        ruleSliLabelSelectors: sliSpec.ruleSliLabelSelectors,
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
    {
      // unsure how to add to this expression
      record: 'sqs_high_latency_in_queue_avg',
      expr: |||
        (%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s} > bool %(metricTarget)s) or vector(0)
      ||| % {
        oldestMessageMetric: metricConfig.metrics.oldestMessage,
        selectors: std.join(',', ruleSelectors),
        queueSelector: metricConfig.standardQueueSelector,
        metricTarget: sliSpec.metricTarget,
      },
      labels: sliSpec.sliLabels,
    },
  ];

// Creates additional detail dashboard templates for this SLI type
// @param direction Whether the dashboard is for inbound or outbound metrics
// @returns List of Grafana template objects
local createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction) =
  [

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
    
  ]);

// File exports
{
  description: 'Age of oldest message in SQS queue should be less than %(metricTarget)s seconds for %(sliDescription)s',
  category: 'Pipeline Freshness',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction): createDetailDashboardTemplates(sliType, metrics, otherConfig, selectors, direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, otherConfig, selectors, direction),
}

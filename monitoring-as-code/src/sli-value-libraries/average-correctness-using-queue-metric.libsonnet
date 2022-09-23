// Divides the sum of if visible message metric samples above one by the sum of count over time of
// target metric samples

// Target metrics:
// visibleMessages - Metric representing the number of visible messages
// oldestMessage - Metric representing the age of oldest message

// Additional config:
// deadletterQueueName custom selector label in metric type config
// deadletterQueueName custom selector in metric type config

// MaC imports
local sliValueLibraryFunctions = import '../util/sli-value-library-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;

// Creates the custom SLI value rule
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @param config The config for the service defined in the mixin file
// @returns JSON defining the recording rule
local createSliValueRule(sliSpec, sliMetadata, config) =
  local metricConfig = sliValueLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliValueLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);
  local targetMetrics = sliValueLibraryFunctions.getTargetMetrics(metricConfig, sliSpec);
  local selectorLabels = sliValueLibraryFunctions.getSelectorLabels(metricConfig);

  [
    {
      record: 'sli_value',
      expr: |||
        sum without (%(selectorLabels)s) (label_replace(label_replace(
          (
            sum by(%(selectorLabels)s) (avg_over_time((%(visibleMessagesMetric)s{%(selectors)s, %(queueSelector)s} >= bool 1)[%(evalInterval)s:%(evalInterval)s]))
            /
            sum by(%(selectorLabels)s) (count_over_time(%(visibleMessagesMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]))
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        visibleMessagesMetric: targetMetrics.visibleMessages,
        queueSelector: '%s!~"%s"' % [metricConfig.customSelectorLabels.deadletterQueueName, metricConfig.customSelectors.deadletterQueueName],
        selectorLabels: std.join(', ', std.objectValues(selectorLabels)),
        environmentSelectorLabel: selectorLabels.environment,
        productSelectorLabel: selectorLabels.product,
        selectors: std.join(', ', ruleSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// Creates Grafana dashboard graph panel
// @param sliSpec The spec for the SLI having its dashboard created
// @returns Grafana graph panel object
local createGraphPanel(sliSpec) =
  local metricConfig = sliValueLibraryFunctions.getMetricConfig(sliSpec);
  local dashboardSelectors = sliValueLibraryFunctions.createDashboardSelectors(metricConfig, sliSpec);
  local targetMetrics = sliValueLibraryFunctions.getTargetMetrics(metricConfig, sliSpec);

  graphPanel.new(
    title='%s' % sliSpec.sliDescription,
    datasource='prometheus',
    description=|||
      * Sample interval is %(evalInterval)s
      * Selectors are %(selectors)s
    ||| % {
      selectors: std.strReplace(std.join(', ', sliValueLibraryFunctions.getSelectors(metricConfig, sliSpec)), '~', '\\~'),
      evalInterval: sliSpec.evalInterval,
    },
    min=0,
    fill=0,
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time(%(visibleMessagesMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        visibleMessagesMetric: targetMetrics.visibleMessages,
        queueSelector: '%s!~"%s"' % [metricConfig.customSelectorLabels.deadletterQueueName, metricConfig.customSelectors.deadletterQueueName],
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg number of msgs visible in dlq',
    )
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time((%(visibleMessagesMetric)s{%(selectors)s, %(queueSelector)s} >= bool 1)[%(evalInterval)s:%(evalInterval)s]) or vector(0))
        /
        sum(count_over_time(%(visibleMessagesMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]))
      ||| % {
        visibleMessagesMetric: targetMetrics.visibleMessages,
        queueSelector: '%s!~"%s"' % [metricConfig.customSelectorLabels.deadletterQueueName, metricConfig.customSelectors.deadletterQueueName],
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg period where msgs in dlq >= 1',
    )
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time(%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        oldestMessageMetric: targetMetrics.oldestMessage,
        queueSelector: '%s!~"%s"' % [metricConfig.customSelectorLabels.deadletterQueueName, metricConfig.customSelectors.deadletterQueueName],
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg age of oldest msg in dlq (secs)',
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

// File exports
{
  createSliValueRule(sliSpec, sliMetadata, config): createSliValueRule(sliSpec, sliMetadata, config),
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
}

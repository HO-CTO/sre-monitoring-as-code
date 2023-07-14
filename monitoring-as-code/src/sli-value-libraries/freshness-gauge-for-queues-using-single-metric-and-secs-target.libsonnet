// Divides the sum of if target metric samples above latency target by the sum of count over time of
// target metric samples

// Target metrics:
// oldestMessage - Metric representing the age of oldest message
// deletedMessages - Metric representing the number of deleted messages

// Additional config:
// counterSecondsTarget in SLI spec
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
            sum by(%(selectorLabels)s) (avg_over_time((%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s} > bool %(counterSecondsTarget)s)[%(evalInterval)s:%(evalInterval)s]))
            /
            count by(%(selectorLabels)s) (count_over_time(%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]))
          ),
        "sli_environment", "$1", "%(environmentSelectorLabel)s", "(.*)"), "sli_product", "$1", "%(productSelectorLabel)s", "(.*)"))
      ||| % {
        oldestMessageMetric: targetMetrics.oldestMessage,
        queueSelector: '%s!~"%s"' % [metricConfig.customSelectorLabels.deadletterQueueName, metricConfig.customSelectors.deadletterQueueName],
        counterSecondsTarget: sliSpec.counterSecondsTarget,
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
        sum(avg_over_time(%(deletedMessagesMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]) or vector(0))
      ||| % {
        deletedMessagesMetric: targetMetrics.deletedMessages,
        queueSelector: '%s!~"%s"' % [metricConfig.customSelectorLabels.deadletterQueueName, metricConfig.customSelectors.deadletterQueueName],
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg number of msgs delivered',
    ),
  ).addTarget(
    prometheus.target(
      |||
        sum(avg_over_time((%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s} > bool %(counterSecondsTarget)s)[%(evalInterval)s:%(evalInterval)s]) or vector(0))
        /
        count(count_over_time(%(oldestMessageMetric)s{%(selectors)s, %(queueSelector)s}[%(evalInterval)s]))
      ||| % {
        oldestMessageMetric: targetMetrics.oldestMessage,
        queueSelector: '%s!~"%s"' % [metricConfig.customSelectorLabels.deadletterQueueName, metricConfig.customSelectors.deadletterQueueName],
        counterSecondsTarget: sliSpec.counterSecondsTarget,
        selectors: std.join(',', dashboardSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      legendFormat='avg period where msg in standard queue > %s seconds' % sliSpec.counterSecondsTarget,
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

// File exports
{
  createSliValueRule(sliSpec, sliMetadata, config): createSliValueRule(sliSpec, sliMetadata, config),
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
}

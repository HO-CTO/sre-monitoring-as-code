// Library to generate Grafana and Prometheus config for generic availability

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
    ||| % {
      evalInterval: sliSpec.evalInterval,
    },
    datasource = 'prometheus',
    min = 0,
    fill = 0,
    thresholds = [
      {
        value: sliSpec.metricTarget,
        colorMode: 'critical',
        op: 'gt',
        line: 'true',
        fill: 'true',
      },
    ]
  ).addTarget(
    prometheus.target(
      'sum(sum_over_time(%(durationMetric)s{%(selectors)s}[%(evalInterval)s])) / 
        sum(count_over_time(%(durationMetric)s{%(selectors)s}[%(evalInterval)s]))' % {
          durationMetric: metricConfig.metrics.duration,
          selectors: std.join(',', dashboardSelectors),
          evalInterval: sliSpec.evalInterval,
        },
      legendFormat = 'Average %s' % sliSpec.sliDescription,
    ),
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
        sum(sum_over_time(%(durationMetric)s{%(selectors)s}[%(evalInterval)s])) / 
        sum(count_over_time(%(durationMetric)s{%(selectors)s}[%(evalInterval)s]))
      ||| % {
        durationMetric: metricConfig.metrics.duration,
        selectors: std.join(',', ruleSelectors),
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
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
  description: 'the average of %(sliDescription)s should be %(comparison)s %(metricTarget)0.1f',
  category: 'Availability',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(direction): createDetailDashboardTemplates(direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction),
}

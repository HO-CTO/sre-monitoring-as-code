// Template for SLI metric libraries

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
  local targetMetrics = sliMetricLibraryFunctions.getTargetMetrics(metricConfig, sliSpec);

  graphPanel.new(
    title = '%s' % sliSpec.sliDescription,
    datasource = 'prometheus',
  );

// Creates custom recording rules for an SLI type
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @param config The config for the service defined in the mixin file
// @returns JSON defining the recording rules
local createCustomRecordingRules(sliSpec, sliMetadata, config) =
  local metricConfig = sliMetricLibraryFunctions.getMetricConfig(sliSpec);
  local ruleSelectors = sliMetricLibraryFunctions.createRuleSelectors(metricConfig, sliSpec, config);
  local targetMetrics = sliMetricLibraryFunctions.getTargetMetrics(metricConfig, sliSpec);

  [
    {
      record: 'sli_value',
      expr: |||
      ||| % {
        evalInterval: sliSpec.evalInterval,
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// File exports
{
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
}

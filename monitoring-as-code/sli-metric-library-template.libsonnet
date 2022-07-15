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

  graphPanel.new(
    title = '%s' % sliSpec.title,
    datasource = 'prometheus',
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
      ||| % {
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
  description: '',
  category: '',
  createGraphPanel(sliSpec): createGraphPanel(sliSpec),
  createCustomRecordingRules(sliSpec, sliMetadata, config): createCustomRecordingRules(sliSpec, sliMetadata, config),
  createDetailDashboardTemplates(direction): createDetailDashboardTemplates(direction),
  createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction): createDetailDashboardPanels(sliType, metrics, selectorLabels, selectors, direction),
}

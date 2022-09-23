// This file contains shared functions for SLI metric libraries

// MaC imports
local macConfig = import '../mac-config.libsonnet';

// Gets the config for the metric defined in SLI spec
// @param sliSpec The spec for the SLI currently being processed
// @returns Object containing config for a metric type
local getMetricConfig(sliSpec) =
  macConfig.metricTypes[sliSpec.metricType].metricTypeConfig;

// Gets a selector using the selector label and selector value from mixin
// @param selector The field for the selector
// @param metricConfig Object containing config for a metric type
// @param sliSpec The spec for the SLI currently being processed
// @returns The selector as a string
local getSelector(selector, metricConfig, sliSpec) =
  '%s=~"%s"' % [metricConfig.selectorLabels[selector], sliSpec.selectors[selector]];

// Gets the list of selectors for an SLI excluding error and environment
// @param metricConfig Object containing config for a metric type
// @param sliSpec The spec for the SLI currently being processed
// @returns List of strings for the selectors
local getSelectors(metricConfig, sliSpec) =
  [
    getSelector(selector, metricConfig, sliSpec)
    for selector in std.objectFields(sliSpec.selectors)
    if selector != 'errorStatus'
  ];

// Creates the list of selectors used for dashboards
// @param metricConfig Object containing config for a metric type
// @param sliSpec The spec for the SLI currently being processed
// @returns List of strings for the selectors
local createDashboardSelectors(metricConfig, sliSpec) =
  std.flattenArrays([
    getSelectors(metricConfig, sliSpec)
    +
    ['%s=~"$environment"' % metricConfig.selectorLabels.environment],
  ]);

// Creates the list of selectors used for recording rules
// @param metricConfig Object containing config for a metric type
// @param sliSpec The spec for the SLI currently being processed
// @param config The config for the service defined in the mixin file
// @returns List of strings for the selectors
local createRuleSelectors(metricConfig, sliSpec, config) =
  std.flattenArrays([
    getSelectors(metricConfig, sliSpec)
    +
    ['%s=~"%s"' % [
      metricConfig.selectorLabels.environment,
      if std.objectHas(config, 'generic') && config.generic then '.*' else config.environment,
    ]],
  ]);

// Gets a custom selector using the selector label and selector value from config
// @param selector The field for the selector
// @param metricConfig Object containing config for a metric type
// @returns The selector as a string
local getCustomSelector(selector, metricConfig) =
  '%s=~"%s"' % [metricConfig.customSelectorLabels[selector], metricConfig.customSelectors[selector]];

// Gets target metrics for an SLI type
// @param metricConfig Object containing config for a metric type
// @param sliSpec The spec for the SLI currently being processed
// @returns The target metric as a string
local getTargetMetrics(metricConfig, sliSpec) =
  {
    [targetMetricField]: metricConfig.metrics[macConfig.metricTypes[sliSpec.metricType].sliTypesConfig[sliSpec.sliType].targetMetrics[targetMetricField]]
    for targetMetricField in std.objectFields(macConfig.metricTypes[sliSpec.metricType].sliTypesConfig[sliSpec.sliType].targetMetrics)
  };

// Gets the environment and product selector labels for a metric type
// @param metricConfig Object containing config for a metric type
// @returns List of the labels
local getSelectorLabels(metricConfig) =
  {
    environment: metricConfig.selectorLabels.environment,
    product: metricConfig.selectorLabels.product,
  };

// File exports
{
  getMetricConfig(sliSpec): getMetricConfig(sliSpec),
  getSelector(selector, metricConfig, sliSpec): getSelector(selector, metricConfig, sliSpec),
  getSelectors(metricConfig, sliSpec): getSelectors(metricConfig, sliSpec),
  createDashboardSelectors(metricConfig, sliSpec): createDashboardSelectors(metricConfig, sliSpec),
  createRuleSelectors(metricConfig, sliSpec, config): createRuleSelectors(metricConfig, sliSpec, config),
  getCustomSelector(selector, metricConfig): getCustomSelector(selector, metricConfig),
  getTargetMetrics(metricConfig, sliSpec): getTargetMetrics(metricConfig, sliSpec),
  getSelectorLabels(metricConfig): getSelectorLabels(metricConfig),
}

// This file is for creating the generic and unique recording rules for an SLI

// MaC imports
local macConfig = import '../mac-config.libsonnet';

// Creates metadata about the type and category of the SLI
// @param category The category of the SLI type
// @param sliSpec The spec for the SLI having metadata created
// @returns JSON containing metadata about the type and category of the SLI
local createSliMetadata(sliSpec) =
  {
    type: sliSpec.sliType,
    category: macConfig.sliMetricLibs[sliSpec.sliType].library.category,
  };

// Creates standard recording rules that are the same for all SLI types
// @param sliSpec The spec for the SLI having its recording rules created
// @param sliMetadata Metadata about the type and category of the SLI
// @returns JSON defining the recording rules
local createStandardRecordingRules(sliSpec, sliMetadata) =
  [
    {
      record: 'sli_percentage',
      expr: |||
        (sum(sum_over_time((sli_value{%(ruleSliLabelSelectors)s} %(comparison)s bool %(metricTarget)s)[30d:%(evalInterval)s]) 
        or vector(0)) / sum(sum_over_time((sli_value{%(ruleSliLabelSelectors)s} < bool Inf)[30d:%(evalInterval)s]) 
        or vector(0))) >= 0
      ||| % {
        ruleSliLabelSelectors: sliSpec.ruleSliLabelSelectors,
        evalInterval: sliSpec.evalInterval,
        metricTarget: sliSpec.metricTarget,
        comparison: if std.objectHas(sliSpec, 'comparison') then sliSpec.comparison else '<',
      },
      labels: sliSpec.sliLabels + sliMetadata,
    },
  ];

// Creates recording rules for an SLI
// @param sliSpec The spec for the SLI having its recording rules created
// @returns JSON defining the recording rules
local createRecordingRules(sliSpec, config) =
  local sliMetadata = createSliMetadata(sliSpec);

  {
    recording_rules+: std.flattenArrays([createStandardRecordingRules(sliSpec, sliMetadata),
      macConfig.sliMetricLibs[sliSpec.sliType].library.createCustomRecordingRules(sliSpec, sliMetadata, config)]),
  };

// File exports
{
  createRecordingRules(sliSpec, config): createRecordingRules(sliSpec, config),
}

// This file is for creating the generic and unique recording rules for an SLI

// MaC imports
local macConfig = import '../mac-config.libsonnet';

// Creates metadata about the type and category of the SLI
// @param category The category of the SLI type
// @param sliSpec The spec for the SLI having metadata created
// @returns JSON containing metadata about the type and category of the SLI
local createSliMetadata(sliSpec) =
  {
    sli_type: sliSpec.sliType,
    metric_type: sliSpec.metricType,
    metric_sli_type: sliSpec.metricType + ':' + sliSpec.sliType,
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
        (
          sum by(sli_environment, sli_product) (sum_over_time((sli_value{%(ruleSliLabelSelectors)s, sli_type="%(sliType)s"} %(comparison)s bool %(metricTarget)s)[30d:%(evalInterval)s]))
          /
          sum by(sli_environment, sli_product) (sum_over_time((sli_value{%(ruleSliLabelSelectors)s, sli_type="%(sliType)s"} < bool Inf)[30d:%(evalInterval)s]))
        ) >= 0
      ||| % {
        ruleSliLabelSelectors: sliSpec.ruleSliLabelSelectors,
        sliType: sliSpec.sliType,
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
    recording_rules+: std.flattenArrays([
      createStandardRecordingRules(sliSpec, sliMetadata),
      macConfig.metricTypes[sliSpec.metricType].sliTypesConfig[sliSpec.sliType].library.createSliValueRule(sliSpec, sliMetadata, config),
    ]),
  };

// File exports
{
  createRecordingRules(sliSpec, config): createRecordingRules(sliSpec, config),
}

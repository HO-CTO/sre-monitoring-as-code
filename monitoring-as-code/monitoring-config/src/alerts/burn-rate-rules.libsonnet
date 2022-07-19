// This file is for generating the error budget burn rules which are used to trigger alerts

// MaC imports
local macConfig = import '../mac-config.libsonnet';

// Gets all of the long and short windows and puts them in an array
// @returns Array containing all of the long and short windows
local getBurnRateWindowArray() =
  std.set([
    burnRateWindow.short
    for burnRateWindow in macConfig.burnRateWindowList
  ] + [
    burnRateWindow.long
    for burnRateWindow in macConfig.burnRateWindowList
  ]);

// Creates the error budget burn rate recording rules for an SLI
// @param sliSpec The spec for the SLI having its alerting rules created
// @returns The list of burn rate rules for an SLI
local createBurnRateRules(sliSpec) =
  {  
    recording_rules+: [
      {
        expr: |||
          (
            1 -
            (
              sum(sum_over_time((sli_value{%(sliLabelSelectors)s} %(comparison)s bool %(target)s)[%(burnRateWindow)s:%(evalInterval)s]))
              /
              (sum(sum_over_time((sli_value{%(sliLabelSelectors)s} < bool Inf)[%(burnRateWindow)s:%(evalInterval)s])) > 0)
            )
          )
          /
          %(sloTarget).5f or vector(0)
        ||| % {
          sliLabelSelectors: sliSpec.ruleSliLabelSelectors,
          burnRateWindow: burnRateWindow,
          sloTarget: (100 - sliSpec.sloTarget) / 100,
          evalInterval: sliSpec.evalInterval,
          target: sliSpec.metricTarget,
          comparison: if std.objectHas(sliSpec, 'comparison') then sliSpec.comparison else '<',
        },
        labels: sliSpec.sliLabels,
        record: macConfig.burnRateRuleNameTemplate % burnRateWindow,
      }
      for burnRateWindow in getBurnRateWindowArray()
    ],
  };

// File exports
{
  createBurnRateRules(sliSpec): createBurnRateRules(sliSpec),
}

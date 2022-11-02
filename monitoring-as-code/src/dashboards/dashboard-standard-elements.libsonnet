// This file is for creating the standard elements used across dashboards for an SLI

// MaC imports
local macConfig = import '../mac-config.libsonnet';
local cFLUtil = import '../util/string-formatting-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local statPanel = grafana.statPanel;
local template = grafana.template;

// Creates a text panel to present the documentation for a dashboard
// @param dashboardName The dashboard name to determine which docs from macConfig should be published in the content
// @returns Grafana Text Panel with published contents.
local createDocsTextPanel(dashboardName) =
  grafana.text.new(
    title=null,
    content='%s' % dashboardName,
    mode='markdown',
    datasource=null,
    transparent=true
  );

// Creates the description for an SLI
// @param sliSpec The spec for the SLI having its standard elements created
// @returns The description for the SLI
local createSliDescription(sliSpec) =
  macConfig.metricTypes[sliSpec.metricType].sliTypesConfig[sliSpec.sliType].description % {
    sliDescription: sliSpec.sliDescription,
    metricTarget: sliSpec.metricTarget,
    metric_target_percent: sliSpec.metricTarget * 100,
    latencyPercentile: sliSpec.latencyPercentile * 100,
    comparison: if std.objectHas(sliSpec, 'comparison') then sliSpec.comparison else '<',
  };

// Creates the long and short row titles for an SLI
// @param sliKey The key of the current SLI having dashboards generated
// @param sliSpec The spec for the SLI having its standard elements created
// @returns The long and short row titles as JSON
local createRowTitles(sliKey, sliSpec) =
  // Row title to describe SLI/SLO
  {
    rowTitle: '%(slo)s %(sliType)s: %(title)s' % {
      slo: sliKey,
      sliType: sliSpec.sliType,
      title: sliSpec.title,
    },
    rowTitleShort: '%(slo)s %(sliType)s (%(period)s)' % {
      slo: sliKey,
      sliType: sliSpec.sliType,
      period: sliSpec.period,
    },
  };

// Creates the dashboard panel for SLI performance
// @param sloTargetLegend The SLO target to be used as the panel legend
// @param sliSpec The spec for the SLI having its standard elements created
// @returns The availability panel object
local createAvailabilityPanel(sloTargetLegend, sliSpec) =
  statPanel.new(
    title=' %(sliType)s (%(period)s)' % { sliType: cFLUtil.capitaliseFirstLetters(sliSpec.sliType), period: sliSpec.period },
    datasource='prometheus',
    colorMode='background',
    reducerFunction='lastNotNull',
    unit='percentunit',
    justifyMode='center',
    noValue='No SLO Data Available',
    graphMode='none',
  ).addTarget(
    prometheus.target(
      |||
        sum(sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"}
        %(comparison)s bool %(target)s)[%(period)s:%(evalInterval)s]))
        /
        sum(sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"}
        < bool Inf)[%(period)s:%(evalInterval)s]) > 0)
      ||| % {
        sliLabelSelectors: sliSpec.dashboardSliLabelSelectors,
        sliType: sliSpec.sliType,
        period: sliSpec.period,
        target: sliSpec.metricTarget,
        evalInterval: sliSpec.evalInterval,
        comparison: if std.objectHas(sliSpec, 'comparison') then sliSpec.comparison else '<',
      },
      // to avoid displaying floating point numbers with a long tail of decimals, .1f will round it
      // to a single decimal
      legendFormat='SLO Target %(%s).1f %%' % sloTargetLegend,
      instant=true,
    )
  ).addThresholds(
    [
      { color: 'grey', value: null },
      { color: 'red', value: 0 },
      { color: 'orange', value: sliSpec.sloTarget / 100 },
      { color: 'green', value: sliSpec.sloTarget / 98 },
    ],
  ) + { options+: { textMode: 'Value and name' } };

// Creates the target expresion for an sli
// @param sli The SLI that we are creating the expresion for
// @returns The string expresion for the target
local getExprFromSli(sli, periodSli) =
  |||
    sum( sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"} %(comparison)s bool %(target)s)[%(period)s:%(evalInterval)s]) )
    / 
    sum(sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"} < bool Inf)[%(period)s:%(evalInterval)s]) > 0)
  ||| % {
    sliLabelSelectors: sli.dashboardSliLabelSelectors,
    sliType: sli.sliType,
    period: periodSli,
    evalInterval: sli.evalInterval,
    target: sli.metricTarget,
    comparison: if std.objectHas(sli, 'comparison') then sli.comparison else '<',
  };

// Creates the averaged panel for SLI performance
// @param sloTargetLegend The SLO target to be used as the panel legend
// @param sliSpec The spec for the SLI having its standard elements created
// @param fullExpr The full expersion for the average dashbaord
// @returns The average panel object

local createAveragedSliTypesPanel(sloTargetLegend, sliSpec, fullExpr) =
  statPanel.new(
    title='SLO Performance (%(period)s)' % { period: sliSpec.slo_period },
    datasource='prometheus',
    colorMode='background',
    reducerFunction='lastNotNull',
    unit='percentunit',
    justifyMode='center',
    noValue='No SLO Data Available',
    graphMode='none',
  ).addTarget(
    prometheus.target(
      expr=fullExpr,
      // to avoid displaying floating point numbers with a long tail of decimals, .1f will round it
      // to a single decimal
      legendFormat='SLO Target %(%s).1f %%' % sloTargetLegend,
      instant=true,
    )
  ).addThresholds(
    [
      { color: 'grey', value: null },
      { color: 'red', value: 0 },
      { color: 'orange', value: sloTargetLegend / 100 },
      { color: 'green', value: sloTargetLegend / 98 },
    ],
  ) + { options+: { textMode: 'Value and name' } };

// Creates the dashboard panel for remaining error budget
// @param sliSpec The spec for the SLI having its standard elements created
// @returns The error budget panel object
local createErrorBudgetPanel(sliSpec) =
  graphPanel.new(
    'Error budget remaining over previous %(period)s' % { period: sliSpec.period },
    datasource='prometheus',
    format='percentunit',
    max=1,
    decimals=2,
    linewidth=3,
    time_from='$error_budget_span',
    thresholds=[
      { value: 0, op: 'lt', colorMode: 'critical', fill: false, line: true },
      { value: 0.5, op: 'lt', colorMode: 'warning', fill: false, line: true },
    ],
  ).addTarget(
    prometheus.target(
      |||
        (%(target)s - (1 - (sum(sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"}
        %(comparison)s bool %(metricTarget)s)[%(period)s:%(evalInterval)s]))
        /
        sum(sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"}
        < bool Inf)[%(period)s:%(evalInterval)s])))))
        /
        %(target)s
      ||| % {
        sliLabelSelectors: sliSpec.dashboardSliLabelSelectors,
        sliType: sliSpec.sliType,
        period: sliSpec.period,
        evalInterval: sliSpec.evalInterval,
        target: (100 - sliSpec.sloTarget) / 100,
        metricTarget: sliSpec.metricTarget,
        comparison: if std.objectHas(sliSpec, 'comparison') then sliSpec.comparison else '<',
      },
      legendFormat='Remaining Error Budget',
    )
  );

// Creates the dashboard panel for SLO status
// @param sliDescription The description for the current SLI
// @param sliSpec The spec for the SLI having its standard elements created
// @returns The SLO status panel object
local createSloStatusPanel(sliDescription, sliSpec) =
  graphPanel.new(
    title=null,
    description=sliDescription,
    datasource='prometheus',
    lines=true,
    staircase=true,
    fill=10,
    linewidth=0,
    stack=true,
    legend_show=false,
    show_xaxis=false,
  ).resetYaxes(
  ).addYaxis(
    show=false, min=0, max=1
  ).addYaxis(
    show=false, min=0, max=1
  ).addTarget(
    // Proportion of intervals SLO has pased
    prometheus.target(
      |||
        sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"} %(comparison)s bool %(target)s)[$__interval:%(evalInterval)s])
        / 
        sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"} < bool Inf)[$__interval:%(evalInterval)s])
      ||| % {
        sliLabelSelectors: sliSpec.dashboardSliLabelSelectors,
        sliType: sliSpec.sliType,
        evalInterval: sliSpec.evalInterval,
        target: sliSpec.metricTarget,
        comparison: if std.objectHas(sliSpec, 'comparison') then sliSpec.comparison else '<',
      },
      legendFormat='SLO OK',
    )
  ).addTarget(
    // Proportion of intervals SLO has failed
    prometheus.target(
      |||
        1 - (
          sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"} %(comparison)s bool %(target)s)[$__interval:%(evalInterval)s])
          / 
          sum_over_time((sli_value{%(sliLabelSelectors)s, sli_type="%(sliType)s"} < bool Inf)[$__interval:%(evalInterval)s])
        )
      ||| % {
        sliLabelSelectors: sliSpec.dashboardSliLabelSelectors,
        sliType: sliSpec.sliType,
        evalInterval: sliSpec.evalInterval,
        target: sliSpec.metricTarget,
        comparison: if std.objectHas(sliSpec, 'comparison') then sliSpec.comparison else '<',
      },
      legendFormat='SLO Fail',
    )
  ).addSeriesOverride(
    {
      alias: '/SLO OK/',
      // Green colour which displays well on dashboard
      color: '#73BF69',
    },
  ).addSeriesOverride(
    {
      alias: '/SLO Fail/',
      color: 'red',
    },
  );

// Creates the standard dashboard elements for an SLI
// @param sliKey The key of the current SLI having dashboards generated
// @param journeyKey The key of the journey containing the SLI having dashboards generated
// @param sliSpec The spec for the SLI having its standard elements created
// @param config The config for the service defined in the mixin file
// @returns The JSON defining the standard dashboard panels, error budget and alert rules
local createDashboardStandardElements(sliKey, journeyKey, sliSpec, config) =
  local sliDescription = createSliDescription(sliSpec);

  local rowTitles = createRowTitles(sliKey, sliSpec);

  {
    row_title: rowTitles.rowTitle,
    row_title_short: rowTitles.rowTitleShort,

    // Grafana panel showing SLO availability over reporting period
    slo_availability_panel: createAvailabilityPanel(sliSpec.sloTarget, sliSpec),

    // Creates certain values needed for the average products view panel
    slo_period: sliSpec.period,
    slo_expr: getExprFromSli(sliSpec, self.slo_period),
    slo_target: sliSpec.sloTarget,
    slo_desc: sliSpec.sliDescription,

    // Grafana panel showing remaining error budget over rolling period
    error_budget_panel: createErrorBudgetPanel(sliSpec),

    // Grafana panel showing SLO status over time
    slo_status_panel: createSloStatusPanel(sliDescription, sliSpec),

    graph: macConfig.metricTypes[sliSpec.metricType].sliTypesConfig[sliSpec.sliType].library.createGraphPanel(sliSpec),
  };

// Creates the templates for dashboards of a service
// @param config The config for the service defined in the mixin file
// @returns List of Grafana template objects
local createServiceTemplates(config) =
  [
    template.new(
      name='environment',
      datasource='prometheus',
      query='label_values(sli_value{service="%s"}, sli_environment)' % config.product,
      refresh='time',
      includeAll=true,
      multi=true,
      label='Environment',
    ),
  ]
  +
  if std.objectHas(config, 'generic') && config.generic then [
    template.new(
      name='metric_type',
      datasource='prometheus',
      query='label_values(sli_value{service="%s", sli_environment=~"$environment"}, metric_type)' % config.product,
      refresh='time',
      includeAll=true,
      multi=true,
      label='Metric Type',
    ),
    template.new(
      name='product',
      datasource='prometheus',
      query='label_values(sli_value{service="%s", sli_environment=~"$environment", metric_type=~"$metric_type"}, sli_product)' % config.product,
      refresh='time',
      includeAll=true,
      multi=true,
      label='Product',
    ),
  ] else [];

// File exports
{
  createDashboardStandardElements(sliKey, journeyKey, sliSpec, config):
    createDashboardStandardElements(sliKey, journeyKey, sliSpec, config),
  createServiceTemplates(config): createServiceTemplates(config),
  createAveragedSliTypesPanel(sloTargetLegend, sliSpec, expr): createAveragedSliTypesPanel(sloTargetLegend, sliSpec, expr),
  createDocsTextPanel(dashboardName): createDocsTextPanel(dashboardName),
}

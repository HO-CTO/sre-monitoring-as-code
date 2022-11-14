// This file is for generating the product dashboard which shows an overview of all of the SLI
// performances for a service

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
// local row = grafana.row;
local prometheus = grafana.prometheus;
// local graphPanel = grafana.graphPanel;
local statPanel = grafana.statPanel;


// MaC imports
local macConfig = import '../mac-config.libsonnet';
// local dashboardFunctions = import './dashboard-standard-elements.libsonnet';
//local debug = import '../util/debug.libsonnet';
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';
local genericSloTarget = 90;
local genericMetricTarget = 10;
local genericEvalInterval = '5m';
local genericPeriod = '30d';

// The maximum number of view panels that can be placed in a row (not the same as row panel)
// local viewPanelsPerRow = 6;

// The width and height of the view panels
// local viewPanelSize = {
//   x: 4,
//   y: 4,
// };

// Creates a row panel which is used to contain all of the SLIs in each journey
// @param journeyIndex The index of the current journey having its panels created
// @param noOfPanelRows The number of rows of view panels that have been created
// @param sliList The list of SLIs for a service
// @returns The row panel object
// local createRow(journeyIndex, noOfPanelRows, sliList) =
//   local journeyKey = std.objectFields(sliList)[journeyIndex];

//   [
//     row.new(
//       title='%(journey)s' % { journey: journeyKey }
//     ) + { gridPos: { x: 0, y: (journeyIndex) + (noOfPanelRows * viewPanelSize.y) - viewPanelSize.y, w: 24, h: 1 } },
//   ];

local createSloErrorStatusPanel() =
  statPanel.new(
    title='$metric_sli_type',
    datasource='prometheus',
    colorMode='background',
    reducerFunction='lastNotNull',
    unit='percentunit',
    justifyMode='center',
    noValue='No SLO Data Available',
    graphMode='none',
    repeat='metric_sli_type',
    repeatDirection='h',
  ).addTarget(
    // SLO Status
    prometheus.target(
      |||
        sum(sum_over_time((sli_value{service="generic", metric_sli_type=~"$metric_sli_type", sli_environment=~"$environment"} < bool  sli_value{metric_sli_type=~"$metric_sli_type",  metric_target=~"$metric_target"} )[%(period)s:%(evalInterval)s]))
        /
        sum(sum_over_time((sli_value{service="generic", metric_sli_type=~"$metric_sli_type", sli_environment=~"$environment"} < bool Inf)[%(period)s:%(evalInterval)s]) > 0)
      ||| % {
        // evalInterval: '30d',
        evalInterval: genericEvalInterval,
        target: genericMetricTarget,
        //target: 'metric_target=~"$metric_target"',
        //period: '30d',
        period: genericPeriod,
      },
      // prometheus.target(
      //   |||
      //     sum(sum_over_time((sli_value{service="generic", metric_sli_type=~"$metric_sli_type", sli_environment=~"$environment"} < bool %(target)s)[%(period)s:%(evalInterval)s]))
      //     /
      //     sum(sum_over_time((sli_value{service="generic", metric_sli_type=~"$metric_sli_type", sli_environment=~"$environment"} < bool Inf)[%(period)s:%(evalInterval)s]) > 0)
      //   ||| % {
      //     // evalInterval: '30d',
      //     evalInterval: genericEvalInterval,
      //     target: genericMetricTarget,
      //     //target: 'metric_target=~"$metric_target"',
      //     //period: '30d',
      //     period: genericPeriod,
      //   },
      legendFormat='SLO Status',
    )
  ).addTarget(
    // Proportion Error Budget
    // prometheus.target(
    //   |||
    //     (%(target)s - (1 - (sum(sum_over_time((sli_value{service="generic", metric_sli_type=~"$metric_sli_type", sli_environment=~"$environment"} < bool %(metricTarget)s)[%(period)s:%(evalInterval)s]))
    //     /
    //     sum(sum_over_time((sli_value{service="generic", metric_sli_type=~"$metric_sli_type", sli_environment=~"$environment"} < bool Inf)[%(period)s:%(evalInterval)s])))))
    //     /
    //     %(target)s
    //   ||| % {

    //     evalInterval: genericEvalInterval,
    //     //        metricTarget: sliSpec.metricTarget,
    //     target: (100 - genericSloTarget) / 100,

    //     metricTarget: genericMetricTarget,
    //     period: genericPeriod,
    //   },
    prometheus.target(
      |||
        (%(target)s - (1 - (sum(sum_over_time((sli_value{service="generic", metric_sli_type=~"$metric_sli_type", sli_environment=~"$environment"} < bool sli_value{service="generic", metric_sli_type=~"$metric_sli_type",  metric_target=~"$metric_target"})[%(period)s:%(evalInterval)s]))
        /
        sum(sum_over_time((sli_value{service="generic", metric_sli_type=~"$metric_sli_type", sli_environment=~"$environment"} < bool Inf)[%(period)s:%(evalInterval)s])))))
        /
        %(target)s
      ||| % {

        evalInterval: genericEvalInterval,
        //        metricTarget: sliSpec.metricTarget,
        target: (100 - genericSloTarget) / 100,

        metricTarget: genericMetricTarget,
        period: genericPeriod,
      },
      legendFormat='Remaining Error Budget',
    )
  ).addTarget(
    // SLO Target
    prometheus.target(
      |||
        %(target)s
      ||| % {
        //target: '0.90',
        target: (genericSloTarget / 100),
      },
      legendFormat='SLO Target',
    )
  ).addThresholds(
    [
      { color: 'grey', value: null },
      { color: 'red', value: 0 },
      { color: 'red', value: -99999 },  // minus numbers will now be red instead of grey
      //     { color: 'orange', value: sliSpec.sloTarget / 100 },
      { color: 'orange', value: genericSloTarget / 100 },
      { color: 'green', value: genericSloTarget / 98 },
    ],
    // ) + { options+: { textMode: 'Value and name' } } + { fieldConfig+: {
    //   overrides+:
    //     [
    //       {
    //         matcher: { id: 'byName', options: 'SLO Target' },
    //         properties: [{ id: 'colour', value: { fixedColor: '010101fc', mode: 'fixed' }}],
    //       },
    //     ],
    //     }
    // };
  ) + { options+: { textMode: 'Value and name' } } + {
    overrides+:
      [
        {
          matcher: { id: 'byName', options: 'SLO Target' },
          //  properties: [{ id: 'colour', value: { fixedColor: '010101fc', mode: 'fixed' } }],
          properties: [{ id: 'colour', value: { fixedColor: 'black', mode: 'fixed' } }],
        },
      ],
  };


// Creates the product dashboard containing a row panel for each journey and then a view panel for
// each SLI in that journey under the row panel
// @param config The config for the service defined in the mixin file
// @param sliList The list of SLIs for a service
// @param links The links to other dashboards
// @returns The JSON defining the product dashboard

local createGenericProductDashboard(config, sliList, links) =

  //  if std.objectHas(config, 'generic') && config.generic then
  //  local panels = createPanels(0, 0, 0, config, sliList);
  //  local panels = createSloErrorStatusPanel("sliDescription", sliSpec);
  local panel = createSloErrorStatusPanel();

  {
    [std.join('-', [macConfig.macDashboardPrefix.uid, config.product]) + '-dynamic.json']:
      dashboard.new(
        title=stringFormattingFunctions.capitaliseFirstLetters(std.join(' / ', [macConfig.macDashboardPrefix.title, config.product]) + ' / dynamic'),
        uid=std.join('-', [macConfig.macDashboardPrefix.uid, config.product + '-dynamic']),
        tags=[config.product, 'mac-version: %s' % config.macVersion, 'product-view'],
        schemaVersion=18,
        editable=true,
        time_from='now-3h',
        refresh='5m'
      ).addLinks(
        dashboardLinks=links
      ).addTemplates(
        config.templates
      ).addPanel(panel, gridPos={ h: 4, w: 4, x: 0, y: 0 }),
  };

// File exports
{
  createGenericProductDashboard(config, sliList, links): createGenericProductDashboard(config, sliList, links),
}

// This file is for generating the product dashboard which shows an overview of all of the SLI
// performances for a service

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;

// MaC imports
local macConfig = import '../mac-config.libsonnet';
local dashboardFunctions = import './dashboard-standard-elements.libsonnet';
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';

// The maximum number of view panels that can be placed in a row (not the same as row panel)
local viewPanelsPerRow = 6;

// The width and height of the view panels
local viewPanelSize = {
  x: 4,
  y: 4,
};

// Creates a row panel which is used to contain all of the SLIs in each journey
// @param journeyIndex The index of the current journey having its panels created
// @param noOfPanelRows The number of rows of view panels that have been created
// @param sliList The list of SLIs for a service
// @returns The row panel object
local createRow(journeyIndex, noOfPanelRows, sliList) =
  local journeyKey = std.objectFields(sliList)[journeyIndex];

  [
    row.new(
      title='%(journey)s' % { journey: journeyKey }
    ) + { gridPos: { x: 0, y: (journeyIndex) + (noOfPanelRows * viewPanelSize.y) - viewPanelSize.y, w: 24, h: 1 } },
  ];

// Creates a view panel which is used to show the performance for each SLI
// @param journeyIndex The index of the current journey having its panels created
// @param sliIndex The index of the current SLI having its panel created
// @param noOfPanelRows The number of rows of view panels that have been created
// @param config The config for the service defined in the mixin file
// @param sliList The list of SLIs for a service
// @returns The view panel object
local createView(journeyIndex, sliIndex, noOfPanelRows, config, sliList) =
  local journeyKey = std.objectFields(sliList)[journeyIndex];
  local slis = std.objectValues(sliList[journeyKey])[sliIndex];

  // Array of all the expressions for the slis
  local exprArray(sliList) =
    [
      sliList[sliKey].slo_expr
      for sliKey in std.objectFields(sliList)
    ];

  // Joining the arrays with a +
  local topExpr = std.join(' + ', exprArray(slis));

  // Final average expression
  local avgExpr =
    |||
      ( %(sumOfSlis)s  ) / %(noOfSlis)s
    ||| % {
      sumOfSlis: topExpr,
      noOfSlis: std.length(slis),
    };

  [
    dashboardFunctions.createAveragedSliTypesPanel(slis[std.objectFields(slis)[0]].slo_target, slis[std.objectFields(slis)[0]], avgExpr)
    +
    {
      gridPos: { x: viewPanelSize.x * (sliIndex % viewPanelsPerRow), y: (journeyIndex + 1) +
                                                                        (noOfPanelRows * viewPanelSize.y) - viewPanelSize.y, w: viewPanelSize.x, h: viewPanelSize.y },
      title: '%(sliTitle)s (%(period)s)' % { sliTitle: slis[std.objectFields(slis)[0]].title, period: slis[std.objectFields(slis)[0]].slo_period },
      description: '%(sliKey)s: %(sliDesc)s' % { sliKey: slis[std.objectFields(slis)[0]].key, sliDesc: slis[std.objectFields(slis)[0]].slo_desc },
      fieldConfig+: {
        defaults+: {
          links: [
            {
              title: 'Full %s Journey SLI dashboard' % journeyKey,
              url: 'd/%s?${environment:queryparam}' % std.join('-', [macConfig.macDashboardPrefix.uid, config.product, journeyKey]),
            },
          ],
        },
      },
    },
  ];

// Recursive function that creates all of the row and view panels for the journeys and SLIs of the
// service
// @param journeyIndex The index of the current journey having its panels created
// @param sliIndex The index of the current SLI having its panel created
// @param noOfPanelRows The number of rows of view panels that have been created
// @param config The config for the service defined in the mixin file
// @param sliList The list of SLIs for a service
// @returns The JSON for all of the panels in the product dashboard
local createPanels(journeyIndex, sliIndex, noOfPanelRows, config, sliList) =
  local journeyKey = std.objectFields(sliList)[journeyIndex];
  local noOfSlis = std.length(std.objectValues(sliList[journeyKey]));
  local noOfJourneys = std.length(std.objectFields(sliList));

  // if last sli in current journey has already been added then either ends recursion or moves to next journey
  if sliIndex == noOfSlis then
    // if last journey in sli list returns empty list and ends recursion
    if journeyIndex == noOfJourneys - 1 then
      []
    // else recursively calls itself for start of next journey
    else
      createPanels(journeyIndex + 1, 0, noOfPanelRows, config, sliList)
  // else adds new panels for current sli
  else
    // increments the number of view panel rows if the current view panel will be on a new row
    local newNoOfPanelRows = if sliIndex % viewPanelsPerRow == 0 then noOfPanelRows + 1 else noOfPanelRows;

    // if first sli in journey creates row and view panel then recursively calls itself for next sli in journey
    if sliIndex == 0 then
      std.flattenArrays([
        createRow(journeyIndex, newNoOfPanelRows, sliList)
        + createView(journeyIndex, sliIndex, newNoOfPanelRows, config, sliList)
        + createPanels(journeyIndex, sliIndex + 1, newNoOfPanelRows, config, sliList),
      ])
    // else creates view panel then recursively calls itself for next sli in journey
    else
      std.flattenArrays([
        createView(journeyIndex, sliIndex, newNoOfPanelRows, config, sliList)
        + createPanels(journeyIndex, sliIndex + 1, newNoOfPanelRows, config, sliList),
      ]);

// Creates the product dashboard containing a row panel for each journey and then a view panel for
// each SLI in that journey under the row panel
// @param config The config for the service defined in the mixin file
// @param sliList The list of SLIs for a service
// @param links The links to other dashboards
// @returns The JSON defining the product dashboard
local createProductDashboard(config, sliList, links) =
  local panels = createPanels(0, 0, 0, config, sliList);

  {
    [std.join('-', [macConfig.macDashboardPrefix.uid, config.product]) + '.json']:
      dashboard.new(
        title=stringFormattingFunctions.capitaliseFirstLetters(std.join(' / ', [macConfig.macDashboardPrefix.title, config.product])),
        uid=std.join('-', [macConfig.macDashboardPrefix.uid, config.product]),
        tags=[config.product, 'mac-version: %s' % config.macVersion, 'product-view'],
        schemaVersion=18,
        editable=true,
        time_from='now-3h',
        refresh='5m'
      ).addLinks(
        dashboardLinks=links
      ).addTemplates(
        config.templates
      ).addPanel(
        dashboardFunctions.createDocsTextPanel(macConfig.dashboardDocs.productView), gridPos={ h: 4, w: 24, x: 0, y: 0 }
      ).addPanels(
        std.prune(panels)
      ),
  };

// File exports
{
  createProductDashboard(config, sliList, links): createProductDashboard(config, sliList, links),
}

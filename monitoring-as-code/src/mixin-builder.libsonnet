// This file is the top level file used for generating all of the dashboards and rules for a product

// MaC imports
local alertFunctions = import './lib/alert-functions.libsonnet';
local dashboardFunctions = import './lib/dashboard-functions.libsonnet';
local sliElementFunctions = import './lib/sli-element-functions.libsonnet';
local macConfig = import './mac-config.libsonnet';

local sliTitleCharLimit = 17;

// Gets a url depending on the type of account
// @param urlType The type of url (Grafana or Alertmanager)
// @param url The non prod url defined in config
// @param account The account type chosen when running framework
// @returns The correct url as a string
local getUrl(urlType, url, account) =
  if account == 'localhost' then
    macConfig.localhostUrls[urlType]
  else
    std.strReplace(url, 'np', account);

// Updates the config passed from mixin file by adding additional values
// @param passedConfig The config defined in the mixin file before being updated
// @returns The updated config
local updateConfig(passedConfig) =
  local environment = std.extVar('ENV');
  local account = std.extVar('ACCOUNT');
  local macVersion = std.extVar('MAC_VERSION');

  passedConfig {
    environment: environment,
    account: account,
    macVersion: macVersion,
    grafanaUrl: getUrl('grafana', passedConfig.grafanaUrl, account),
    alertmanagerUrl: getUrl('alertmanager', passedConfig.alertmanagerUrl, account),
    templates: dashboardFunctions.createServiceTemplates(passedConfig),
  };

// Updates the SLI spec list passed from mixin file by adding additional values
// @param config The config for the service defined in the mixin file
// @param passedSliSpecList The list of SLI specs defined in the mixin file before being updated
// @returns The updated SLI spec list
local updateSliSpecList(config, passedSliSpecList) =
  passedSliSpecList + {
    [journeyKey]+: {
      [sliKey]+: {
        sliLabels: {
          service: config.product,
          sli: sliKey,
          journey: journeyKey,
          mac_version: config.macVersion,
          metric_type: passedSliSpecList[journeyKey][sliKey].metricType,
        },
        dashboardSliLabelSelectors:
          |||
            service="%(service)s", sli="%(sli)s", journey="%(journey)s", metric_type="%(metricType)s",
            sli_environment=~"$environment"%(productSelector)s
          ||| % {
            service: config.product,
            sli: sliKey,
            journey: journeyKey,
            productSelector: if std.objectHas(config, 'generic') && config.generic then ', sli_product=~"$product"' else '',
            metricType: passedSliSpecList[journeyKey][sliKey].metricType,
          },
        ruleSliLabelSelectors:
          |||
            service="%(service)s", sli="%(sli)s", journey="%(journey)s", metric_type="%(metricType)s",
            sli_environment=~"%(environment)s"
          ||| % {
            service: config.product,
            sli: sliKey,
            journey: journeyKey,
            environment: if std.objectHas(config, 'generic') && config.generic then '.*' else config.environment,
            metricType: passedSliSpecList[journeyKey][sliKey].metricType,
          },
      }
      for sliKey in std.objectFields(passedSliSpecList[journeyKey])
    }
    for journeyKey in std.objectFields(passedSliSpecList)
  };

// Adds the current SLI type, metric target, counter seconds target and latency percentile to the SLI spec.
// @param sliType The current SLI type
// @param sliSpec The spec for the SLI having its elements created
// @returns The SLI spec object but with updated SLI type and supplementary target and percentile metadata.
local updateSliSpec(sliType, sliSpec) =
  sliSpec
  {
    // Metric target combines interval targets and histogram seconds targets. These targets are not applied within sli_value expressions and can be used to build standard elements
    metricTarget:
      if std.objectHas(sliSpec.sliTypes[sliType], 'histogramSecondsTarget')
      then sliSpec.sliTypes[sliType].histogramSecondsTarget
      else
        if std.objectHas(sliSpec.sliTypes[sliType], 'intervalTarget')
        then (100 - sliSpec.sliTypes[sliType].intervalTarget) / 100
        else (100 - sliSpec.sloTarget) / 100,

    // CounterSecondsTarget is applied within sli_value expressions and as such does not used for standard elements
    counterSecondsTarget: sliSpec.sliTypes[sliType].counterSecondsTarget,
    latencyPercentile: (sliSpec.sliTypes[sliType].percentile / 100),
    sliType: sliType,
  };

// Creates an SLI with its standard dashboard elements, unique dashboard elements, recording
// rules, alerting rules and alerts
// @param sliType The current SLI type
// @param config The config for the service defined in the mixin file
// @param passedSliSpec The spec for the SLI having its elements created
// @param sliKey The key of the current SLI having rules generated
// @param journeyKey The key of the journey containing the SLI having rules generated
// @returns The SLI with standard elements
local createSli(sliType, config, passedSliSpec, sliKey, journeyKey) =
  if journeyKey == config.product then
    error 'Invalid Journey name [%s]. Journey name cannot match Product name [%s].' % [journeyKey, config.product]
  else if std.length(passedSliSpec.title) > sliTitleCharLimit then
    error 'SLI Title [%s] with [%s] characters is greater than recommended length of [%s].' % [passedSliSpec.title, std.length(passedSliSpec.title), sliTitleCharLimit]
  else
    local sliSpec = updateSliSpec(sliType, passedSliSpec);

    if std.objectHas(macConfig.metricTypes, sliSpec.metricType) then
      if std.objectHas(macConfig.metricTypes[sliSpec.metricType].sliTypesConfig, sliType) then
        sliElementFunctions.createRecordingRules(sliSpec, config) +
        sliElementFunctions.createSliStandardElements(sliKey, sliSpec) +
        dashboardFunctions.createDashboardStandardElements(sliKey, journeyKey, sliSpec, config) +
        alertFunctions.createBurnRateRules(sliSpec) +
        alertFunctions.createBurnRateAlerts(config, sliSpec, sliKey, journeyKey)
      else error 'Metric type %s does not have SLI type %s' % [sliSpec.metricType, sliType]
    else error 'Undefined metric type %s' % sliSpec.metricType;

// Creates a list of all the SLIs in a service with their standard dashboard elements, unique
// dashboard elements, recording rules, alerting rules and alerts
// @param config The config for the service defined in the mixin file
// @param sliSpecList The list of SLI specs defined in the mixin file
// @returns The list of SLIs with standard elements
local createSliList(config, sliSpecList) =
  {
    [journeyKey]+: {
      [sliKey]+: {
        [sliType]+:
          createSli(sliType, config, sliSpecList[journeyKey][sliKey], sliKey, journeyKey)
        for sliType in std.objectFields(sliSpecList[journeyKey][sliKey].sliTypes)
      }
      for sliKey in std.objectFields(sliSpecList[journeyKey])
    }
    for journeyKey in std.objectFields(sliSpecList)
  };

// Creates the links to other dashboards
// @param config The config for the service defined in the mixin file
// @returns A list of the links to other dashboards
local createLinks(config) =
  [
    {
      asDropdown: false,
      icon: 'dashboard',
      includeVars: true,
      tags: ['overview'],
      title: 'Overview',
      type: 'dashboards',
    },
    {
      asDropdown: false,
      icon: 'dashboard',
      includeVars: true,
      tags: [config.product, 'product-view'],
      title: 'product-view',
      type: 'dashboards',
    },
    {
      asDropdown: true,
      icon: 'dashboard',
      includeVars: true,
      tags: [config.product, 'journey-view'],
      title: 'journey-view',
      type: 'dashboards',
    },
    {
      asDropdown: true,
      icon: 'dashboard',
      includeVars: true,
      tags: [config.product, 'detail-view'],
      title: 'detail-view',
      type: 'dashboards',
    },
  ];

// Creates the JSON defining the recording rules for the SLIs in a service
// @param config The config for the service defined in the mixin file
// @param sliList The list of SLIs for a service
// @returns JSON defining the recording rules
local createPrometheusRules(config, sliList) =
  {
    groups+: [{
      name: '%s%srecordingrules' % [
        config.product,
        if std.objectHas(config, 'generic') && config.generic then '_' else '_%s_' % config.environment,
      ],
      rules: std.flattenArrays([
        sli.recording_rules
        for journeyKey in std.objectFields(sliList)
        for sliKey in std.objectFields(sliList[journeyKey])
        for sli in std.objectValues(sliList[journeyKey][sliKey])
      ]),
    }],
  };

// Creates the JSON defining the alerting rules for the SLIs in a service
// @param config The config for the service defined in the mixin file
// @param sliList The list of SLIs for a service
// @returns JSON defining the alerting rules
local createPrometheusAlerts(config, sliList) =
  {
    groups+: [{
      name: '%s%salertrules' % [
        config.product,
        if std.objectHas(config, 'generic') && config.generic then '_' else '_%s_' % config.environment,
      ],
      rules: std.flattenArrays([
        sli.alerts
        for journeyKey in std.objectFields(sliList)
        for sliKey in std.objectFields(sliList[journeyKey])
        for sli in std.objectValues(sliList[journeyKey][sliKey])
      ]),
    }],
  };

// Builds the dashboards and rules for the mixin file it is called from
// @param passedConfig The config defined in the mixin file before being updated
// @param passedSliSpecList The list of SLI specs defined in the mixin file before being updated
// @returns The JSON for the dashboards and rules
local buildMixin(passedConfig, passedSliSpecList) =
  local config = updateConfig(passedConfig);

  local sliSpecList = updateSliSpecList(config, passedSliSpecList);

  local sliList = createSliList(config, sliSpecList);

  // Define standard set of links to use in each dashboard
  local links = createLinks(config);

  {
    grafanaDashboardFolder: config.product,
    grafanaDashboards+: dashboardFunctions.createJourneyDashboards(config, sliList, links) +
                        dashboardFunctions.createProductDashboard(config, sliList, links) +
                        dashboardFunctions.createDetailDashboards(config, links, sliSpecList),

    prometheusRules+: createPrometheusRules(config, sliList),
    prometheusAlerts+: createPrometheusAlerts(config, sliList),
  };

// File exports
{
  buildMixin(passedConfig, passedSliSpecList): buildMixin(passedConfig, passedSliSpecList),
}

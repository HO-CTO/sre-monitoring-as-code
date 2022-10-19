// This file is for generating the error budget burn alerts

// MaC imports
local macConfig = import '../mac-config.libsonnet';

// Gets the severity of the burn rate window depending on what max alert severity has been set to
// in config
// @param errorBudgetBurnWindow The current burn rate window
// @param config The config for the service defined in the mixin file
// @param sliSpec The spec for the SLI having its alerting rules created
// @returns The string of the alerts severity
local getSeverity(errorBudgetBurnWindow, config, sliSpec) =
  // If maxAlertSeverity is set to test at either service or SLO level, set severity to test
  if std.objectHas(config, 'maxAlertSeverity') && config.maxAlertSeverity == 'test' ||
     std.objectHas(sliSpec, 'maxAlertSeverity') && sliSpec.maxAlertSeverity == 'test' then 'test'
  // If maxAlertSeverity is set to warning at either service or SLO level and window severity is critical, set severity to warning
  else if std.objectHas(config, 'maxAlertSeverity') && config.maxAlertSeverity == 'warning' ||
          std.objectHas(sliSpec, 'maxAlertSeverity') && sliSpec.maxAlertSeverity == 'warning' &&
          errorBudgetBurnWindow.severity == 'critical' then 'warning'
  // otherwise use the window severity
  else errorBudgetBurnWindow.severity;

// Creates the title for an alert
// @param errorBudgetBurnWindow The current burn rate window
// @param config The config for the service defined in the mixin file
// @param sliSpec The spec for the SLI having its alerting rules created
// @param sliKey The key of the current SLI having rules generated
// @param journeyKey The key of the journey containing the SLI having rules generated
// @returns The alert title as a string
local createAlertTitle(errorBudgetBurnWindow, config, sliSpec, sliKey, journeyKey) =
  '%(severity)s ALERT! %(environment)s - %(service)s %(slo)s - Percentage of time %(description)s' % {
    service: config.product,
    severity: std.asciiUpper(errorBudgetBurnWindow.severity),
    environment: if std.objectHas(config, 'generic') && config.generic then 'generic' else config.environment,
    description: sliSpec.title,
    factor: errorBudgetBurnWindow.factor,
    journey: journeyKey,
    slo: sliKey,
  };

// Gets all of the items (excluding runbookUrl and configurationItem) from a given object and
// creates a new object with the field names being the name of the object then a dot then the item
// field name
// @param objectName The name of the object as a string
// @param object The actual object
// @returns New object containing the items from the passed object with new field names
local getObjectItems(objectName, object) =
  {
    ['%s.%s' % [objectName, itemField]]: object[itemField]
    for itemField in std.objectFields(object)
    if itemField != 'runbookUrl' && itemField != 'configurationItem'
  };

// Gets all of the values needed for the alert payload
// @param alertName The name of the alert
// @param severity The severity of the alert
// @param alertTitle The title of the alert
// @param errorBudgetBurnWindow The current burn rate window
// @param config The config for the service defined in the mixin file
// @param sliSpec The spec for the SLI having its alerting rules created
// @param sliKey The key of the current SLI having rules generated
// @param journeyKey The key of the journey containing the SLI having rules generated
// @returns Object containing the values needed for the alert payload
local getAlertPayloadConfig(alertName, severity, alertTitle, errorBudgetBurnWindow, config, sliSpec, sliKey, journeyKey) =
  {
    alertName: alertName,
    severity: severity,
    alertTitle: alertTitle,
    sliKey: sliKey,
    journeyKey: journeyKey,
    exhaustionDays: std.parseInt(std.rstripChars(sliSpec.period, 'd')) / errorBudgetBurnWindow.factor,
    runbookUrl: if std.objectHas(config, 'runbookUrl') then config.runbookUrl else 'no runbook',
    configurationItem: if std.objectHas(sliSpec, 'configurationItem') then sliSpec.configurationItem else config.configurationItem,
  }
  +
  getObjectItems('config', config)
  +
  getObjectItems('sliSpec', sliSpec);

// Creates the alert payload by doing string substitution on the alertPayloadTemplate in macConfig
// using the alertPayloadConfig
// @param alertPayloadConfig The object containing the values needed for the alert payload
// @returns Object containing the alert payload with formatted values
local createAlertPayload(alertPayloadConfig) =
  {
    [alertPayloadTemplateField]: macConfig.alertPayloadTemplate[alertPayloadTemplateField] % alertPayloadConfig
    for alertPayloadTemplateField in std.objectFields(macConfig.alertPayloadTemplate)
  };

// Creates a string of the alert payload as a list of bullet points
// @param alertPayload The alert payload object
// @returns String of the alert payload
local createAlertPayloadString(alertPayload) =
  std.join('\n• ', std.map(
    function(alertPayloadField) '*%s:* %s' % [alertPayloadField, alertPayload[alertPayloadField]],
    std.objectFields(alertPayload)
  ));

// Creates alerts for an SLI, one alert for each burn rate window
// @param config The config for the service defined in the mixin file
// @param sliSpec The spec for the SLI having its alerting rules created
// @param sliKey The key of the current SLI having rules generated
// @param journeyKey The key of the journey containing the SLI having rules generated
// @returns A list of JSON objects defining the alerts
local createBurnRateAlerts(config, sliSpec, sliKey, journeyKey) =
  {
    alerts+: [
      {
        local alertName = std.join('_', [std.strReplace(macConfig.macDashboardPrefix.uid, '-', '_'), config.product, journeyKey, sliKey, sliSpec.sliType, 'ErrorBudgetBurn']),
        local severity = getSeverity(errorBudgetBurnWindow, config, sliSpec),
        local alertTitle = createAlertTitle(errorBudgetBurnWindow, config, sliSpec, sliKey, journeyKey),

        local alertPayloadConfig = getAlertPayloadConfig(alertName, severity, alertTitle, errorBudgetBurnWindow, config, sliSpec, sliKey, journeyKey),
        local alertPayload = createAlertPayload(alertPayloadConfig),

        alert: alertName,
        expr: |||
          %(recordingRuleShort)s{%(sliLabelSelectors)s, sli_type="%(sliType)s"} > %(factor).5f
          and
          %(recordingRuleLong)s{%(sliLabelSelectors)s, sli_type="%(sliType)s"} > %(factor).5f
        ||| % {
          recordingRuleShort: macConfig.burnRateRuleNameTemplate % errorBudgetBurnWindow.short,
          recordingRuleLong: macConfig.burnRateRuleNameTemplate % errorBudgetBurnWindow.long,
          sliLabelSelectors: sliSpec.ruleSliLabelSelectors,
          sliType: sliSpec.sliType,
          factor: errorBudgetBurnWindow.factor,
        },
        labels: {
          ci_type: 'CMDB_CI_Service_Auto',
          title: alertTitle,
          wait_for: '%(for)s' % errorBudgetBurnWindow,
          factor: std.toString(errorBudgetBurnWindow.factor),
        } + alertPayload,
        annotations: {
          dashboard: '%(grafanaUrl)s/d/%(journeyUid)s%(environment)s' % {
            grafanaUrl: config.grafanaUrl,
            journeyUid: std.join('-', [macConfig.macDashboardPrefix.uid, config.product, journeyKey]),
            environment: if std.objectHas(config, 'generic') && config.generic then '' else '?var-environment=%s' % config.environment,
          },
          silenceurl: '%(alertmanagerUrl)s/#/silences/new?filter={alertname%%3D%%22%(alertName)s%%22, journey%%3D%%22%(journey)s%%22, service%%3D%%22%(service)s%%22}' % {
            alertmanagerUrl: config.alertmanagerUrl,
            alertName: alertName,
            journey: journeyKey,
            service: config.product,
          },
          description: createAlertPayloadString(alertPayload),
          [if std.objectHas(config, 'runbookUrl') then 'runbookUrl']:
            if std.objectHas(config, 'runbookUrl') then config.runbookUrl,
        },
        'for': '%(for)s' % errorBudgetBurnWindow,
      }
      for errorBudgetBurnWindow in macConfig.burnRateWindowList
    ],
  };

// File exports
{
  createBurnRateAlerts(config, sliSpec, sliKey, journeyKey):
    createBurnRateAlerts(config, sliSpec, sliKey, journeyKey),
}

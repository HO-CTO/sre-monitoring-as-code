// Target metrics:
// sentMessages - Metric representing the number of messages sent
// visibleMessages - Metric representing the number of visible messages
// deletedMessages - Metric representing the number of deleted messages
// oldestMessage - Metric representing the age of oldest message

// Additional config:
// deadletterQueueName custom selector label in metric type config
// deadletterQueueName custom selector in metric type config

// MaC imports
local stringFormattingFunctions = import '../../util/string-formatting-functions.libsonnet';

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graphPanel = grafana.graphPanel;
local row = grafana.row;
local template = grafana.template;
local statPanel = grafana.statPanel;

// Creates custom templates
// @param direction The type of dashboard elements being created, inbound or outbound
// @param metrics Object containing metrics
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @returns List of custom templates
local createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors) =
  std.flattenArrays([
    [
      template.new(
        name='%s_standard_%s' % [direction, selectorLabel],
        label=stringFormattingFunctions.capitaliseFirstLetters('%s Standard %s' % [direction, selectorLabel]),
        datasource='prometheus',
        query='label_values({__name__=~"%(oldestMessageMetrics)s", %(environmentSelectors)s, %(productSelectors)s, %(queueSelectors)s}, %(selectorLabel)s)' % {
          oldestMessageMetrics: std.join('|', metrics.oldestMessage),
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
          queueSelectors: selectors.standardQueue,
          selectorLabel: selectorLabel,
        },
        current='all',
        includeAll=true,
        multi=true,
        refresh='time',
      )
      for selectorLabel in customSelectorLabels.deadletterQueueName
    ] + [
      template.new(
        name='%s_deadletter_%s' % [direction, selectorLabel],
        label=stringFormattingFunctions.capitaliseFirstLetters('%s Deadletter %s' % [direction, selectorLabel]),
        datasource='prometheus',
        query='label_values({__name__=~"%(oldestMessageMetrics)s", %(environmentSelectors)s, %(productSelectors)s, %(queueSelectors)s}, %(selectorLabel)s)' % {
          oldestMessageMetrics: std.join('|', metrics.oldestMessage),
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
          queueSelectors: selectors.deadletterQueue,
          selectorLabel: selectorLabel,
        },
        current='all',
        includeAll=true,
        multi=true,
        refresh='time',
      )
      for selectorLabel in customSelectorLabels.deadletterQueueName
    ],
  ]);

// Creates custom selectors
// @param direction The type of dashboard elements being created, inbound or outbound
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @returns List of custom selectors
local createCustomSelectors(direction, customSelectorLabels, customSelectorValues) =
  {
    standardQueueTemplate: std.join(', ', std.map(
      function(selectorLabel) '%(selectorLabel)s=~"$%(direction)s_standard_%(selectorLabel)s|"' % {
        selectorLabel: selectorLabel,
        direction: direction,
      },
      customSelectorLabels.deadletterQueueName
    )),
    deadletterQueueTemplate: std.join(', ', std.map(
      function(selectorLabel) '%(selectorLabel)s=~"$%(direction)s_deadletter_%(selectorLabel)s|"' % {
        selectorLabel: selectorLabel,
        direction: direction,
      },
      customSelectorLabels.deadletterQueueName
    )),
    standardQueue: std.join(', ', std.map(
      function(selectorLabel) '%s!~"%s|"' % [selectorLabel, std.join('|', customSelectorValues.deadletterQueueName)],
      customSelectorLabels.deadletterQueueName
    )),
    deadletterQueue: std.join(', ', std.map(
      function(selectorLabel) '%s=~"%s|"' % [selectorLabel, std.join('|', customSelectorValues.deadletterQueueName)],
      customSelectorLabels.deadletterQueueName
    )),
  };

// Creates panels
// @param direction The type of dashboard elements being created, inbound or outbound
// @param metrics Object containing metrics
// @param selectorLabels Object containing selector labels
// @param customSelectorLabels Object containing custom selector labels
// @param customSelectorValues Object containing custom selector values
// @param selectors Object containing selectors
// @returns List of panels
local createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors) =
  std.flattenArrays([
    [row.new(
      title=stringFormattingFunctions.capitaliseFirstLetters('%s Cloudwatch SQS' % direction),
    ) + { gridPos: { w: 24, h: 1 } }],
    [statPanel.new(
      // SQS messages age of oldest message in DLQ queues
      title='SQS - Approx age of oldest message in Dead Letter Queues',
      datasource='prometheus',
      unit='s',
      justifyMode='center',
    ).addTarget(
      prometheus.target(|||
                          sum by (%(deadletterQueueNameSelectorLabels)s) ({__name__=~"%(oldestMessageMetrics)s", %(queueSelectors)s,
                          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
                        ||| % {
                          deadletterQueueNameSelectorLabels: std.join(', ', customSelectorLabels.deadletterQueueName),
                          oldestMessageMetrics: std.join('|', metrics.oldestMessage),
                          queueSelectors: selectors.deadletterQueue,
                          queueTemplateSelectors: selectors.deadletterQueueTemplate,
                          environmentSelectors: selectors.environment,
                          productSelectors: selectors.product,
                        },
                        legendFormat='{{%s}}' % std.join(', ', customSelectorLabels.deadletterQueueName))
    ) + { options+: { textMode: 'value_and_name' } } + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages visible in DLQs
      title='SQS - Messages visible in Dead Letter Queues',
      datasource='prometheus',
      min=0,
    ).addTarget(
      prometheus.target(|||
                          sum by (%(deadletterQueueNameSelectorLabels)s) ({__name__=~"%(visibleMessagesMetrics)s", %(queueSelectors)s,
                          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
                        ||| % {
                          deadletterQueueNameSelectorLabels: std.join(', ', customSelectorLabels.deadletterQueueName),
                          visibleMessagesMetrics: std.join('|', metrics.visibleMessages),
                          queueSelectors: selectors.deadletterQueue,
                          queueTemplateSelectors: selectors.deadletterQueueTemplate,
                          environmentSelectors: selectors.environment,
                          productSelectors: selectors.product,
                        },
                        legendFormat='{{%s}}' % std.join(', ', customSelectorLabels.deadletterQueueName))
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
    [statPanel.new(
      // SQS messages age of oldest message in standard queues
      title='SQS - Approx age of oldest message in standard queues',
      datasource='prometheus',
      unit='s',
      justifyMode='center',
    ).addTarget(
      prometheus.target(|||
                          sum by (%(deadletterQueueNameSelectorLabels)s) ({__name__=~"%(oldestMessageMetrics)s", %(queueSelectors)s,
                          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
                        ||| % {
                          deadletterQueueNameSelectorLabels: std.join(', ', customSelectorLabels.deadletterQueueName),
                          oldestMessageMetrics: std.join('|', metrics.oldestMessage),
                          queueSelectors: selectors.standardQueue,
                          queueTemplateSelectors: selectors.standardQueueTemplate,
                          environmentSelectors: selectors.environment,
                          productSelectors: selectors.product,
                        },
                        legendFormat='{{%s}}' % std.join(', ', customSelectorLabels.deadletterQueueName))
    ) + { options+: { textMode: 'value_and_name' } } + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages visible in standard queues
      title='SQS - Messages visible in standard queues',
      datasource='prometheus',
      min=0,
    ).addTarget(
      prometheus.target(|||
                          sum by (%(deadletterQueueNameSelectorLabels)s) ({__name__=~"%(visibleMessagesMetrics)s", %(queueSelectors)s,
                          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
                        ||| % {
                          deadletterQueueNameSelectorLabels: std.join(', ', customSelectorLabels.deadletterQueueName),
                          visibleMessagesMetrics: std.join('|', metrics.visibleMessages),
                          queueSelectors: selectors.standardQueue,
                          queueTemplateSelectors: selectors.standardQueueTemplate,
                          environmentSelectors: selectors.environment,
                          productSelectors: selectors.product,
                        },
                        legendFormat='{{%s}}' % std.join(', ', customSelectorLabels.deadletterQueueName))
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
    [graphPanel.new(
      // SQS messages sent - standard queues
      title='SQS - Messages sent (standard queues)',
      datasource='prometheus',
      min=0,
    ).addTarget(
      prometheus.target(|||
                          sum by (%(deadletterQueueNameSelectorLabels)s) ({__name__=~"%(sentMessagesMetrics)s", %(queueSelectors)s,
                          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
                        ||| % {
                          deadletterQueueNameSelectorLabels: std.join(', ', customSelectorLabels.deadletterQueueName),
                          sentMessagesMetrics: std.join('|', metrics.sentMessages),
                          queueSelectors: selectors.standardQueue,
                          queueTemplateSelectors: selectors.standardQueueTemplate,
                          environmentSelectors: selectors.environment,
                          productSelectors: selectors.product,
                        },
                        legendFormat='{{%s}}' % std.join(', ', customSelectorLabels.deadletterQueueName))
    ) + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages deleted - in standard queues
      title='SQS - Messages deleted (standard queues)',
      datasource='prometheus',
      min=0,
    ).addTarget(
      prometheus.target(|||
                          sum by (%(deadletterQueueNameSelectorLabels)s) ({__name__=~"%(deletedMessagesMetrics)s", %(queueSelectors)s,
                          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
                        ||| % {
                          deadletterQueueNameSelectorLabels: std.join(', ', customSelectorLabels.deadletterQueueName),
                          deletedMessagesMetrics: std.join('|', metrics.deletedMessages),
                          queueSelectors: selectors.standardQueue,
                          queueTemplateSelectors: selectors.standardQueueTemplate,
                          environmentSelectors: selectors.environment,
                          productSelectors: selectors.product,
                        },
                        legendFormat='{{%s}}' % std.join(', ', customSelectorLabels.deadletterQueueName))
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
  ]);

// File exports
{
  createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors):
    createCustomTemplates(direction, metrics, customSelectorLabels, customSelectorValues, selectors),
  createCustomSelectors(direction, customSelectorLabels, customSelectorValues):
    createCustomSelectors(direction, customSelectorLabels, customSelectorValues),
  createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors):
    createPanels(direction, metrics, selectorLabels, customSelectorLabels, customSelectorValues, selectors),
}

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
        name = '%s_standard_%s' % [direction, selectorLabel],
        label = stringFormattingFunctions.capitaliseFirstLetters('%s Standard %s' % [direction, selectorLabel]),
        datasource = 'prometheus',
        query = 'label_values({__name__=~"%(oldestMessageMetrics)s", %(environmentSelectors)s, %(productSelectors)s, %(queueSelectors)s}, %(selectorLabel)s)' % {
          oldestMessageMetrics: std.join('|', metrics.oldestMessage),
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
          queueSelectors: selectors.standardQueue,
          selectorLabel: selectorLabel,
        },
        current = 'all',
        includeAll = true,
        multi = true,
        refresh = 'time',
      )
      for selectorLabel in customSelectorLabels.targetQueue
    ] + [
      template.new(
        name = '%s_deadletter_%s' % [direction, selectorLabel],
        label = stringFormattingFunctions.capitaliseFirstLetters('%s Deadletter %s' % [direction, selectorLabel]),
        datasource = 'prometheus',
        query = 'label_values({__name__=~"%(oldestMessageMetrics)s", %(environmentSelectors)s, %(productSelectors)s, %(queueSelectors)s}, %(selectorLabel)s)' % {
          oldestMessageMetrics: std.join('|', metrics.oldestMessage),
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
          queueSelectors: selectors.deadletterQueue,
          selectorLabel: selectorLabel,
        },
        current = 'all',
        includeAll = true,
        multi = true,
        refresh = 'time',
      )
      for selectorLabel in customSelectorLabels.targetQueue
    ]
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
      customSelectorLabels.targetQueue
    )),
    deadletterQueueTemplate: std.join(', ', std.map(
      function(selectorLabel) '%(selectorLabel)s=~"$%(direction)s_deadletter_%(selectorLabel)s|"' % {
        selectorLabel: selectorLabel,
        direction: direction,
      },
      customSelectorLabels.targetQueue
    )),
    standardQueue: std.join(', ', std.map(
      function(selectorLabel) '%s!~"%s|"' % [selectorLabel, std.join('|', customSelectorValues.deadletterQueueType)],
      customSelectorLabels.deadletterQueueType
    )),
    deadletterQueue: std.join(', ', std.map(
      function(selectorLabel) '%s=~"%s|"' % [selectorLabel, std.join('|', customSelectorValues.deadletterQueueType)],
      customSelectorLabels.deadletterQueueType
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
      title = stringFormattingFunctions.capitaliseFirstLetters('%s Cloudwatch SQS' % direction),
    ) + { gridPos: { w: 24, h: 1 } }],
    [statPanel.new(
      // SQS messages age of oldest message in DLQ queues
      title = 'SQS - Approx age of oldest message in Dead Letter Queues',
      datasource = 'prometheus',
      unit = 's',
      justifyMode = 'center',
    ).addTarget(
      prometheus.target(|||
          sum by (%(targetQueueSelectorLabels)s) ({__name__=~"%(oldestMessageMetrics)s", %(queueSelectors)s,
          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
        ||| % {
          targetQueueSelectorLabels: std.join(', ', customSelectorLabels.targetQueue),
          oldestMessageMetrics: std.join('|', metrics.oldestMessage),
          queueSelectors: selectors.deadletterQueue,
          queueTemplateSelectors: selectors.deadletterQueueTemplate,
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
        }, 
        legendFormat = '{{%s}}' % std.join(', ', customSelectorLabels.targetQueue))
    ) + { options+: { textMode: 'value_and_name' } } + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages visible in DLQs
      title = 'SQS - Messages visible in Dead Letter Queues',
      datasource = 'prometheus',
      min = 0,
    ).addTarget(
      prometheus.target(|||
          sum by (%(targetQueueSelectorLabels)s) ({__name__=~"%(messagesVisibleMetrics)s", %(queueSelectors)s,
          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
        ||| % {
          targetQueueSelectorLabels: std.join(', ', customSelectorLabels.targetQueue),
          messagesVisibleMetrics: std.join('|', metrics.messagesVisible),
          queueSelectors: selectors.deadletterQueue,
          queueTemplateSelectors: selectors.deadletterQueueTemplate,
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
        },
        legendFormat = '{{%s}}' % std.join(', ', customSelectorLabels.targetQueue))
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
    [statPanel.new(
      // SQS messages age of oldest message in standard queues
      title = 'SQS - Approx age of oldest message in standard queues',
      datasource = 'prometheus',
      unit = 's',
      justifyMode = 'center',
    ).addTarget(
      prometheus.target(|||
          sum by (dimension_QueueName) ({__name__=~"%(oldestMessageMetrics)s", %(queueSelectors)s,
          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
        ||| % {
          targetQueueSelectorLabels: std.join(', ', customSelectorLabels.targetQueue),
          oldestMessageMetrics: std.join('|', metrics.oldestMessage),
          queueSelectors: selectors.standardQueue,
          queueTemplateSelectors: selectors.standardQueueTemplate,
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
        }, 
        legendFormat = '{{%s}}' % std.join(', ', customSelectorLabels.targetQueue))
    ) + { options+: { textMode: 'value_and_name' } } + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages visible in standard queues
      title = 'SQS - Messages visible in standard queues',
      datasource = 'prometheus',
      min = 0,
    ).addTarget(
      prometheus.target(|||
          sum by (%(targetQueueSelectorLabels)s) ({__name__=~"%(messagesVisibleMetrics)s", %(queueSelectors)s,
          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
        ||| % {
          targetQueueSelectorLabels: std.join(', ', customSelectorLabels.targetQueue),
          messagesVisibleMetrics: std.join('|', metrics.messagesVisible),
          queueSelectors: selectors.standardQueue,
          queueTemplateSelectors: selectors.standardQueueTemplate,
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
        },
        legendFormat = '{{%s}}' % std.join(', ', customSelectorLabels.targetQueue))
    ) + { gridPos: { w: 12, h: 10, x: 12 } }],
    [graphPanel.new(
      // SQS messages sent - standard queues
      title = 'SQS - Messages sent (standard queues)',
      datasource = 'prometheus',
      min = 0,
    ).addTarget(
      prometheus.target(|||
          sum by (%(targetQueueSelectorLabels)s) ({__name__=~"%(messagesSentMetrics)s", %(queueSelectors)s,
          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
        ||| % {
          targetQueueSelectorLabels: std.join(', ', customSelectorLabels.targetQueue),
          messagesSentMetrics: std.join('|', metrics.messagesSent),
          queueSelectors: selectors.standardQueue,
          queueTemplateSelectors: selectors.standardQueueTemplate,
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
        },
        legendFormat = '{{%s}}' % std.join(', ', customSelectorLabels.targetQueue))
    ) + { gridPos: { w: 12, h: 10 } }],
    [graphPanel.new(
      // SQS messages deleted - in standard queues
      title = 'SQS - Messages deleted (standard queues)',
      datasource = 'prometheus',
      min = 0,
    ).addTarget(
      prometheus.target(|||
          sum by (%(targetQueueSelectorLabels)s) ({__name__=~"%(messagesDeletedMetrics)s", %(queueSelectors)s,
          %(queueTemplateSelectors)s, %(environmentSelectors)s, %(productSelectors)s})
        ||| % {
          targetQueueSelectorLabels: std.join(', ', customSelectorLabels.targetQueue),
          messagesDeletedMetrics: std.join('|', metrics.messagesDeleted),
          queueSelectors: selectors.standardQueue,
          queueTemplateSelectors: selectors.standardQueueTemplate,
          environmentSelectors: selectors.environment,
          productSelectors: selectors.product,
        },
        legendFormat = '{{%s}}' % std.join(', ', customSelectorLabels.targetQueue))
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

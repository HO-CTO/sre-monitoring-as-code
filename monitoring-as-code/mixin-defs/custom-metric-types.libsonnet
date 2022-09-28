{
  simple_counter_total: {
    metricTypeConfig: {
      selectorLabels: {
        environment: 'namespace',
        product: 'job',
        errorStatus: 'status',
      },
      metrics: {
        counter: 'simple_counter_total',
      },
    },
    sliTypesConfig: {
      success_transactions: {
        library: (import '../src/sli-value-libraries/proportion-of-errors-using-label.libsonnet'),
        description: 'The average of a single metric %(sliDescription)s should be %(metric_target_percent)0.1f%%',
        targetMetrics: {
          target: 'counter',
        },
      },
    },
    outboundMetrics: {
        counter: 'simple_counter_total',
    },
    detailDashboardConfig: {
      standardTemplates: ['environment', 'product'],
      elements: ["customMetric"],
      targetMetrics: {
        target: 'counter'
      },
    },
  }
}
<template>
  <div>
    <Version/> 
    <GaugeTable v-if="gauge_metrics" :gaugeMetrics="gauge_metrics" /> 
  </div>
</template>

<script setup>
import Version from "../components/Version.vue"
import GaugeTable from "../components/GaugeTable.vue"

import {client} from '../utils/axios'
</script>

<script>
export default {
  async mounted() {
    this.getGaugeValue()
  },
  data(){
    return {
      gauge_metrics: null
    }
  },
  methods: {
    async getGaugeValue(){
      this.gauge_metrics = null;
      const response = await client.get("/gauges");
      this.gauge_metrics = response.data;
    }
  },
}
</script>

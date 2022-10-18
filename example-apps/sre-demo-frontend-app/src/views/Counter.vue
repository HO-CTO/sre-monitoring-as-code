<template>
  <div>
    <Version />
    <CounterInput @counterChange="getCounterValue"/>
    <CounterTable v-if="counter_metrics" :counterMetrics="counter_metrics" />
  </div>
</template>

<script setup>
import Version from "../components/Version.vue";
import CounterTable from "../components/CounterTable.vue";
import CounterInput from "../components/CounterInput.vue";

import {client} from '../utils/axios'
</script>

<script>
export default{
  async mounted(){
    this.getCounterValue()
  },
  data() {
    return {
      counter_metrics: null
    };
  },
  methods: {
    async getCounterValue() {
      this.counter_metrics = null
      const response = await client.get("/counters");
      this.counter_metrics = response.data;
    }
  }
}
</script>
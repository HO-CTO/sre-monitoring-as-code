<template>
  <div class="d-flex" style="gap: 2rem">
    <a
      href="/#/counter"
      class="d-flex flex-column justify-content-center align-items-center border h-250 w-250 no-underline"
    >
      <div style="color: white; font-size: 5em">{{ this.countersCount }}</div>
      <h3>Counters</h3>
    </a>

    <a
      href="/#/gauge"
      class="d-flex flex-column justify-content-center align-items-center border h-250 w-250 no-underline"
    >
      <div style="color: white; font-size: 5em">{{ this.gaugesCount }}</div>
      <h3>Gauges</h3>
    </a>

    <a
      href="/#/histogram"
      class="d-flex flex-column justify-content-center align-items-center border h-250 w-250 no-underline"
    >
      <div style="color: white; font-size: 5em">{{ this.histogramsCount }}</div>
      <h3>Histograms</h3>
    </a>
  </div>
</template>

<script>
import { client } from "../utils/axios";
export default {
  async mounted() {
    await this.refreshCounts();
  },
  data() {
    return {
      countersCount: 0,
      gaugesCount: 0,
      histogramsCount: 0,
    };
  },
  methods: {
    async refreshCounts() {
      const results = await Promise.all([
        client.get("/counters"),
        client.get("/gauges"),
        client.get("/histograms"),
      ]);

      this.countersCount = results?.at(0).data?.length;
      this.gaugesCount = results?.at(1).data?.length;
      this.histogramsCount = results?.at(2).data?.length;
    },
  },
};
</script>

<style>
.no-underline:link,
.no-underline:visited,
.no-underline:hover {
  text-decoration: none;
}
</style>

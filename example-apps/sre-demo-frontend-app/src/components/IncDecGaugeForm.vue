<template>
  <div>
    <h3>{{ capGaugeOption }} Gauge</h3>
    <div>
      <div class="form-group">
        <label
          >Gauge Name
          <input
            class="form-control"
            id="gaugeName"
            type="text"
            autocomplete="off"
            :value="gauge_name"
            readonly
          />
        </label>
      </div>
      <div class="form-group">
        <label
          >Gauge Value
          <input
            class="form-control"
            id="gaugeValue"
            type="number"
            v-model="incDecGaugeValues"
            autocomplete="off"
        /></label>
      </div>
      <div class="form-group">
        <label
          >Gauge labels
          <p class="tiny-font">
            This should be a comma separated list of key-value pairs.
          </p>
          <input
            class="form-control"
            id="gaugeLabels"
            type="text"
            v-model="incDecGaugeLabels"
            placeholder="e.g. status=SUCCESS,path=/homepage"
            autocomplete="off"
        /></label>
      </div>
    </div>
    <button @click="incDecGauge()" class="btn btn-primary" role="button">
      {{ capGaugeOption }} gauge
    </button>
  </div>
</template>

<script>
export default {
  props: ["gauge_name", "gauge_option"],
  emits: ["submitted"],
  data() {
    return {
      incDecGaugeValues: "",
      incDecGaugeLabels: "",
    };
  },
  methods: {
    incDecGauge() {
      this.$emit("submitted", {
        name: this.gauge_name,
        value: this.incDecGaugeValues,
        labels: this.incDecGaugeLabels,
      });
      this.incDecGaugeValues = "";
      this.incDecGaugeLabels = "";
    },
  },
  computed: {
    capGaugeOption() {
      return (
        this.gauge_option.charAt(0).toUpperCase() + this.gauge_option.slice(1)
      );
    },
  },
};
</script>

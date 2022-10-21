<template>
  <div>
    <h3>{{ capHistogramOption }} Histogram</h3>
    <div>
      <div class="form-group">
        <label
          >Histogram Name
          <input
            class="form-control"
            id="histogramName"
            type="text"
            autocomplete="off"
            :value="histogram_name"
            readonly
          />
        </label>
      </div>
      <div class="form-group">
        <label
          >Histogram Value
          <input
            class="form-control"
            id="histogramValue"
            type="number"
            v-model="observeHistogramValues"
            autocomplete="off"
        /></label>
      </div>
      <div class="form-group">
        <label
          >Histogram labels
          <p class="tiny-font">
            This should be a comma separated list of key-value pairs.
          </p>
          <input
            class="form-control"
            id="histogramLabels"
            type="text"
            v-model="observeHistogramLabels"
            placeholder="e.g. status=SUCCESS,path=/homepage"
            autocomplete="off"
        /></label>
      </div>
    </div>
    <button @click="observeHistogram()" class="btn btn-primary" role="button">
      {{ capHistogramOption }} histogram
    </button>
  </div>
</template>

<script>
export default {
  props: ["histogram_name", "histogram_option"],
  emits: ["submitted"],
  data() {
    return {
      observeHistogramValues: "",
      observeHistogramLabels: "",
    };
  },
  methods: {
    observeHistogram() {
      this.$emit("submitted", {
        name: this.histogram_name,
        value: this.observeHistogramValues,
        labels: this.observeHistogramLabels,
      });
      this.observeHistogramValues = "";
      this.observeHistogramLabels = "";
    },
  },
  computed: {
    capHistogramOption() {
      return (
        this.histogram_option.charAt(0).toUpperCase() +
        this.histogram_option.slice(1)
      );
    },
  },
};
</script>

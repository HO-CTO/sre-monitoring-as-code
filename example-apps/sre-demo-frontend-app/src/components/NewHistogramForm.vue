<template>
  <div>
    <h3>Create new histogram</h3>
    <div>
      <div class="form-group">
        <label for="histogramName">Histogram Name</label>
        <input
          class="form-control"
          id="histogramName"
          type="text"
          v-model="createHistogramName"
          autocomplete="off"
        />
      </div>
      <div class="form-group">
        <label for="histogramDesc">Histogram Desc</label>
        <input
          class="form-control"
          id="histogramDesc"
          type="text"
          v-model="createHistogramDesc"
          autocomplete="off"
        />
      </div>
      <div class="form-group">
        <label for="histogramLabels">Histogram labels</label>
        <p class="tiny-font">
          This should be a comma separated list of label names.
        </p>
        <input
          class="form-control"
          id="histogramLabels"
          type="text"
          v-model="createHistogramLabels"
          placeholder="e.g. status,path,resource"
          autocomplete="off"
        />
      </div>
      <div class="form-group">
        <label for="histogramBuckets">Histogram buckets (optional)</label>
        <p class="tiny-font">A comma separated list of bucket values.</p>
        <input
          class="form-control"
          id="histogramBuckets"
          type="text"
          v-model="createHistogramBuckets"
          placeholder="e.g. 1,2,3,5,8,13"
          autocomplete="off"
        />
      </div>
    </div>
    <button @click="createHistogram()" class="btn btn-primary" role="button">
      Create
    </button>
  </div>
</template>

<script>
export default {
  emits: ["created"],
  data() {
    return {
      createHistogramName: "",
      createHistogramDesc: "",
      createHistogramLabels: "",
    };
  },
  methods: {
    createHistogram() {
      this.$emit("created", {
        name: this.createHistogramName,
        description: this.createHistogramDesc,
        labelNames: this.createHistogramLabels,
        bucketsList: this.createHistogramBuckets,
      });

      this.createHistogramName = "";
      this.createHistogramDesc = "";
      this.createHistogramLabels = "";
      this.createHistogramBuckets = "";
    },
  },
};
</script>

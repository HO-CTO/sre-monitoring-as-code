<template>
  <div>
    <h3>Create new gauge</h3>
    <div>
      <div class="form-group">
        <label for="gaugeName">Gauge Name</label>
        <input
          class="form-control"
          id="gaugeName"
          type="text"
          v-model="createGaugeName"
          autocomplete="off"
        />
      </div>
      <div class="form-group">
        <label for="gaugeDesc">Gauge Desc</label>
        <input
          class="form-control"
          id="gaugeDesc"
          type="text"
          v-model="createGaugeDesc"
          autocomplete="off"
        />
      </div>
      <div class="form-group">
        <label for="gaugeLabels">Gauge labels</label>
        <p class="tiny-font">
          This should be a comma separated list of label names.
        </p>
        <input
          class="form-control"
          id="gaugeLabels"
          type="text"
          v-model="createGaugeLabels"
          placeholder="e.g. status,path,resource"
          autocomplete="off"
        />
      </div>
    </div>
    <button @click="createGauge()" class="btn btn-primary" role="button">
      Create
    </button>
  </div>
</template>

<script>
export default {
  emits: ["created"],
  data() {
    return {
      createGaugeName: "",
      createGaugeDesc: "",
      createGaugeLabels: "",
    };
  },
  methods: {
    createGauge() {
      this.$emit("created", {
        name: this.createGaugeName,
        description: this.createGaugeDesc,
        labelNames: this.createGaugeLabels,
      });

      this.createGaugeName = "";
      this.createGaugeDesc = "";
      this.createGaugeLabels = "";
    },
  },
};
</script>

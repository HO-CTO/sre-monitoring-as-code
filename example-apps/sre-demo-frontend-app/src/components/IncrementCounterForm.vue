<template>
  <div>
    <h3>Increment Counter</h3>
    <div>
      <div class="form-group">
        <label
          >Counter Name
          <input
            class="form-control"
            id="counterName"
            type="text"
            :value="this.counter_name"
            autocomplete="off"
            readonly
          />
        </label>
      </div>
      <div class="form-group">
        <label
          >Counter Value
          <input
            class="form-control"
            id="counterValue"
            type="number"
            v-model="incrementCounterValues"
            autocomplete="off"
        /></label>
      </div>
      <div class="form-group">
        <label
          >Counter labels
          <p class="tiny-font">
            This should be a comma separated list of key-value pairs.
          </p>
          <input
            class="form-control"
            id="counterLabels"
            type="text"
            v-model="incrementCounterLabels"
            placeholder="e.g. status=SUCCESS,path=/homepage"
            autocomplete="off"
        /></label>
      </div>
    </div>
    <button @click="incrementCounter()" class="btn btn-primary" role="button">
      Increment counter
    </button>
  </div>
</template>

<script>
export default {
  props: ["counter_name"],
  emits: ["submitted"],
  data() {
    return {
      incrementCounterValues: "",
      incrementCounterLabels: "",
    };
  },
  methods: {
    incrementCounter() {
      this.$emit("submitted", {
        name: this.counter_name,
        value: this.incrementCounterValues,
        labels: this.incrementCounterLabels,
      });

      // this.incrementCounterName = "";
      this.incrementCounterValues = "";
      this.incrementCounterLabels = "";
    },
  },
};
</script>

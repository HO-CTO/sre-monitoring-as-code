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
            v-model="incrementCounterName"
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
        /></label>
      </div>
    </div>
    <button
      @click="
        $emit('submitted', {
          name: this.incrementCounterName,
          value: this.incrementCounterValues,
          labels: this.incrementCounterLabels,
        })
      "
      class="btn btn-primary"
      role="button"
    >
      Increment counter
    </button>
  </div>
</template>

<script>
export default {
  emits: ["submitted"],
  data() {
    return {
      incrementCounterName: "",
      incrementCounterValues: "",
      incrementCounterLabels: "",
    };
  },
};
</script>

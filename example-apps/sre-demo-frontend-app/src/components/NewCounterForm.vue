<template>
  <div>
    <h3>Create new counter</h3>
    <div>
      <div class="form-group">
        <label for="counterName">Counter Name</label>
        <input
          class="form-control"
          id="counterName"
          type="text"
          v-model="createCounterName"
          autocomplete="off"
        />
      </div>
      <div class="form-group">
        <label for="counterDesc">Counter Desc</label>
        <input
          class="form-control"
          id="counterDesc"
          type="text"
          v-model="createCounterDesc"
          autocomplete="off"
        />
      </div>
      <div class="form-group">
        <label for="counterLabels">Counter labels</label>
        <p class="tiny-font">
          This should be a comma separated list of label names.
        </p>
        <input
          class="form-control"
          id="counterLabels"
          type="text"
          v-model="createCounterLabels"
          placeholder="e.g. status,path,resource"
          autocomplete="off"
        />
      </div>
    </div>
    <button @click="createCounter()" class="btn btn-primary" role="button">
      Create
    </button>
  </div>
</template>

<script>
export default {
  emits: ["created"],
  data() {
    return {
      createCounterName: "",
      createCounterDesc: "",
      createCounterLabels: "",
    };
  },
  methods: {
    createCounter() {
      this.$emit("created", {
        name: this.createCounterName,
        description: this.createCounterDesc,
        labelNames: this.createCounterLabels,
      });

      this.createCounterName = "";
      this.createCounterDesc = "";
      this.createCounterLabels = "";
    },
  },
};
</script>

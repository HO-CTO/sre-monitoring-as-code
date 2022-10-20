<template>
  <!-- Make new counter -->
  <h3>Counter Input</h3>

  <!-- Increment counter -->
  <div>
    <label for="counterName">Counter Name</label>
    <input id="counterName" type="text" v-model="incrementCounterName" />
    <label for="counterValue">Counter Value</label>
    <input id="counterValue" type="text" v-model="incrementCounterValues" />
    <label for="counterLabels">Counter labels</label>
    <input id="counterLabels" type="text" v-model="incrementCounterLabels" />
    <button type="button" @click="incrementCounter">
      Submit new increment
    </button>
  </div>
</template>

<script>
import { client } from "../utils/axios";

const initialValues = {
  incrementCounterName: "",
  incrementCounterValues: "",
  incrementCounterLabels: "",
};
export default {
  props: {
    onCounterCreated: Function,
  },
  emits: ["counterCreated", "counterIncremented"],
  data() {
    return { ...initialValues };
  },
  methods: {
    async incrementCounter() {
      let labels = {};
      if (this.incrementCounterLabels.length != 0) {
        let labelSplit = this.incrementCounterLabels.split(",");
        for (let elem in labelSplit) {
          let elemSplit = labelSplit[elem].split("=");
          labels[elemSplit[0]] = elemSplit[1];
        }
      }

      this.$emit("counterIncremented", {
        name: this.incrementCounterName,
        value: parseInt(this.incrementCounterValues),
        labels: labels,
      });
    },
  },
};
</script>

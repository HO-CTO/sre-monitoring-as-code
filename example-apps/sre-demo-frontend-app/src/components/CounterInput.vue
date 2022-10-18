<template>
  <!-- Make new counter -->
  <h3>Counter Input</h3>
  <div>
    <label for="counterName">Counter Name</label>
    <input id="counterName" type="text" v-model="createCounterName"/>
    <label for="counterDesc">Counter Desc</label>
    <input id="counterDesc" type="text" v-model="createCounterDesc"/>
    <label for="counterLabels">Counter labels</label>
    <input id="counterLabels" type="text" v-model="createCounterLabels"/>
    <button type="button" @click="createCounter">Submit new counter</button>
  </div>

  <!-- Increment counter -->
  <div>
    <label for="counterName">Counter Name</label>
    <input id="counterName" type="text" v-model="incrementCounterName"/>
    <label for="counterValue">Counter Value</label>
    <input id="counterValue" type="text" v-model="incrementCounterLabels"/>
    <label for="counterLabels">Counter labels</label>
    <input id="counterLabels" type="text" v-model="incrementCounterValues"/>
    <button type="button" @click="incrementCounter">Submit new increment</button>
  </div>
</template>

<script>
import {client} from '../utils/axios'

const initialValues = {
  createCounterName: "",
  createCounterDesc: "",
  createCounterLabels: "",
  incrementCounterName: "",
  incrementCounterLabels: "",
  incrementCounterValues: "",
}
export default {
  emits: ["counterChange"],
  data() {
    return {...initialValues};
  },
  methods: {
    async createCounter() {
      //TODO: Fix lavels
      const response = await client.post("/counters", {
        name: this.createCounterName,
        description: this.createCounterDesc,
        labelNames: [],
      })
      this.$emit("counterChange")
    },

    incrementCounter(){

    }

    
  }
};
</script>

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
    <input id="counterValue" type="text" v-model="incrementCounterValues"/>
    <label for="counterLabels">Counter labels</label>
    <input id="counterLabels" type="text" v-model="incrementCounterLabels"/>
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
  incrementCounterValues: "",
  incrementCounterLabels: "",
}
export default {
  emits: ["counterChange"],
  data() {
    return {...initialValues};
  },
  methods: {
    async createCounter() {
      let labels = []
      if (this.createCounterLabels.length != 0) {
        labels = this.createCounterLabels.split(",")
      }
      const response = await client.post("/counters", {
        name: this.createCounterName,
        description: this.createCounterDesc,
        labelNames: labels,
      })
      this.$emit("counterChange")
    },

    async incrementCounter(){
      let labels = {}
      // console.log(this.incrementCounterLabels)
      if (this.incrementCounterLabels.length != 0) {
        let labelSplit = this.incrementCounterLabels.split(",")
        for (let elem in labelSplit){
          let elemSplit = labelSplit[elem].split("=")
          labels[elemSplit[0]] = elemSplit[1]
        }
      }
      const response = await client.post(`/counters/${this.incrementCounterName}/increment`, {
        value: parseInt(this.incrementCounterValues),
        labels: labels,
      })
      this.$emit("counterChange")
    }

    
  }
};
</script>

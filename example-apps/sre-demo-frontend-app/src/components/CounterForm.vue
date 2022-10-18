<template>
  <div>
    <h3>Counter metric</h3>
    <div class="container">
      <div class="container" v-if="counterMetrics.length == 0">
        <p>Its empty</p>
      </div>
      <div v-else>
        <div>
          <table class="table">
            <thead>
              <tr>
                <th>Counter Name</th>
                <th>Labels</th>
                <th>Value</th>
              </tr>
            </thead>
            <tbody v-for="counter in counterMetrics">
              <tr v-if="counter.value.length == 0">
                <td>{{ counter.name }}</td>
                <td>no labels</td>
                <td>no value</td>
              </tr>
              <tr v-else v-for="valueElem in counter.value">
                <td>{{ counter.name }}</td>
                <td>{{ valueElem.labels }}</td>
                <td>{{ valueElem.value }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

const client = axios.create({
  baseURL: "http://localhost:4001",
  headers: {
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json"}
});

const initialValues = {
  counterMetrics: []
};

export default {
  async mounted() {
      const response = await client.get("/counters");
      this.counterMetrics = response.data;
     },
  data() {
    return { ...initialValues };
  },
};
</script>

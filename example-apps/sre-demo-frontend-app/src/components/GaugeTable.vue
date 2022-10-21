<template>
  <div>
    <h3>Gauge</h3>
    <div>
      <div class="container">
        <div class="container" v-if="data.length == 0">
          <p>Its empty</p>
        </div>
        <div v-else>
          <div>
            <table class="table">
              <thead>
                <tr>
                  <th>Guage Name</th>
                  <th>Labels</th>
                  <th>Value</th>
                </tr>
              </thead>
              <tbody v-for="(gauge, index) in data" :key="index">
                <tr v-if="gauge.value.length == 0">
                  <td>{{ gauge.name }}</td>
                  <td>no labels</td>
                  <td>no value</td>
                </tr>
                <tr v-else v-for="valueElem in gauge.value">
                  <td>{{ gauge.name }}</td>
                  <td>{{ valueElem.labels }}</td>
                  <td>{{ valueElem.value }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ["gaugeMetrics"],
  data() {
    return {
      data: this.gaugeMetrics,
    };
  },
};
</script>

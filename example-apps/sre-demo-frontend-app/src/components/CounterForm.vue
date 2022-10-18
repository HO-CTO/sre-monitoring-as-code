<template>
  <div>
    <h3>Counter metric</h3>
    <div class="container">
      <div class="container" v-if="dataVals.length == 0">
        <p> Its empty </p>
      </div>
      <div v-else> 
        <div v-for="data in dataVals">
          <table class="table">
            <thead>
              <tr>
                <th> Counter Name</th>
                <th> Labels </th>
                <th> Value </th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="data.value.length == 0">
                <td> {{data.name}} </td>
                <td> no labels </td>
                <td> no value</td>
              </tr>
              <tr v-else v-for=" valueElem in data.value">
                <td> {{data.name}} </td>
                <td> {{valueElem.labels }} </td>
                <td> {{valueElem.value }} </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
const baseApiUrl = "http://localhost:4001";

const headers = {
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json",
};

const initialValues = {
  successfulInput: 1,
  exceptionInput: 1,
  successCounter: null,
  exceptionCounter: null,
  totalCounter: null,
  dataVals: [],
};

export default {
  mounted() {
    fetch(`${baseApiUrl}/counters`, {
      mode: "cors",
      headers,
    })
      .then((data) => data.json())
      .then((data) => {
        this.dataVals = data;
      });
  },
  data() {
    return {...initialValues};
  },
    
};
</script>

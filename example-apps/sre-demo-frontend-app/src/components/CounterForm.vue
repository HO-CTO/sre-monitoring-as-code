<template>
  <div class="container">
    <div class="container">
    <table class="table">
      <thead>
        <tr>
          <th>Successful</th>
          <th>Exceptions</th>
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>{{ successCounter }}</td>
          <td>{{ exceptionCounter }}</td>
          <td>{{ totalCounter }}</td>
        </tr>
      </tbody>
    </table>
    </div>
    <div class="container">
      <div class="row">
        <div class="col-6">
          <form class="form">
        <div class="form-group">
        <label>
          Number of successful event to generate:
          <input name="amount" type="number" class="form-control" v-model="successfulInput" />
        </label>
      </div>
        <button class="btn btn-success" type="button" @click="buttonClick('success', this.successfulInput)">Generate successful</button>

      </form>
        </div>
        <div class="col-6">
          <form class="form">
        <div class="form-group">
        <label>Number of exception events to generate:<input name="amount" type="number" class="form-control" v-model="exceptionInput" /></label>
      </div>
        <button class="btn btn-danger" type="button" @click="buttonClick('exception', this.exceptionInput)">
          Generate exceptions
        </button>

      </form>
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
};

export default {
  mounted() {
    fetch(`${baseApiUrl}/values`, {
      mode: "cors",
      headers,
    })
      .then((data) => data.json())
      .then((data) => {
        this.successCounter = data.good;
        this.exceptionCounter = data.bad;
        this.totalCounter = data.total;
      });
  },
  data() {
    return {...initialValues};
  },
  methods: {
    async buttonClick(endpoint, amount) {
      const res = await fetch(`${baseApiUrl}/${endpoint}`, {
        method: "POST",
        mode: "cors",
        headers,
        body: JSON.stringify({
          amount,
        }),
      });

      const { good, bad, total } = await res.json();
      this.successCounter = good;
      this.exceptionCounter = bad;
      this.totalCounter = total;
    },
  },
};
</script>

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

<template>
  <div class="greetings">
    <table>
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
    <div>
      <form>
        <input name="amount" type="number" v-model="successfulInput" />
        <button type="button" @click="buttonClick('success', this.successfulInput)">Generate successful</button>
      </form>
      <form>
        <input name="amount" type="number" v-model="exceptionInput" />
        <button type="button" @click="buttonClick('exception', this.exceptionInput)">
          Generate exceptions
        </button>
      </form>
    </div>
  </div>
</template>

<style scoped>
h1 {
  font-weight: 500;
  font-size: 2.6rem;
  top: -10px;
}

h3 {
  font-size: 1.2rem;
}

.greetings h1,
.greetings h3 {
  text-align: center;
}

@media (min-width: 1024px) {
  .greetings h1,
  .greetings h3 {
    text-align: left;
  }
}
</style>

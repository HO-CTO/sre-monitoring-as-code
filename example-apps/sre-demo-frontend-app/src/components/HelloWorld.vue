<script setup>
defineProps({
  msg: {
    type: String,
    required: true,
  },
});
</script>

<script>
export default {
  mounted() {
    fetch("http://localhost:8081/values", {
      mode: "cors",
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    })
      .then((data) => data.json())
      .then((data) => {
        this.successCounter = data.good;
        this.exceptionCounter = data.bad;
        this.totalCounter = data.total;
      });
  },
  data() {
    return {
      successfulInput: 1,
      exceptionInput: 1,
      successCounter: null,
      exceptionCounter: null,
      totalCounter: null,
    };
  },
  methods: {
    async successClick() {
      console.log(this.successfulInput);
      const res = await fetch("http://localhost:8081/success", {
        method: "POST",
        body: JSON.stringify({
          amount: this.successfulInput,
        }),
        mode: "cors",
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Content-Type": "application/json",
        },
      });

      const newValues = await res.json();
      this.successCounter = newValues.good;
      this.exceptionCounter = newValues.bad;
      this.totalCounter = newValues.total;
    },
    async exceptionClick() {
      console.log(this.exceptionInput);
      const res = await fetch("http://localhost:8081/exception", {
        method: "POST",
        body: JSON.stringify({
          amount: this.exceptionInput,
        }),
        mode: "cors",
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Content-Type": "application/json",
        },
      });
      const newValues = await res.json();
      this.successCounter = newValues.good;
      this.exceptionCounter = newValues.bad;
      this.totalCounter = newValues.total;
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
        <button type="button" @click="successClick">Generate successful</button>
      </form>
      <form>
        <input name="amount" type="number" v-model="exceptionInput" />
        <button type="button" @click="exceptionClick">
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

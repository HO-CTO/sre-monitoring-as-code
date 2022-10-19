<template>
  <div>
    <div>
      <button class="btn btn-primary">Create new counter</button>
    </div>

    <Modal>
      <NewCounterForm />
    </Modal>

    <!-- <CounterInput
      @counterChange="listCounters"
      @counterCreated="handleCounterCreated"
      @counterIncremented="handleCounterIncremented"
    /> -->
    <CounterTable
      v-if="counter_metrics"
      :counterMetrics="counter_metrics"
      :supportedActions="supportedActions"
      @counterIncremented="handleCounterIncremented"
      @counterDeleted="handleCounterDeleted"
    />
  </div>
</template>

<script setup>
import NewCounterForm from "../components/NewCounterForm.vue";
import CounterTable from "../components/CounterTable.vue";
import CounterInput from "../components/CounterInput.vue";
import Modal from "../components/Modal.vue";

import { client } from "../utils/axios";
</script>

<script>
export default {
  async mounted() {
    await this.listCounters();
  },
  data() {
    return {
      counter_metrics: null,
      supportedActions: {
        increment: true,
        decrement: false,
        setValue: false,
        delete: true,
        observe: false,
      },
    };
  },
  methods: {
    async listCounters() {
      this.counter_metrics = null;
      const response = await client.get("/counters");
      this.counter_metrics = response.data;
    },

    async handleCounterCreated({ name, description, labelNames }) {
      await client.post("/counters", {
        name,
        description,
        labelNames,
      });
      await this.listCounters();
    },

    async handleCounterIncremented({ name, value = 1, labels }) {
      console.log({ labels });
      await client.post(`/counters/${name}/increment`, {
        value,
        labels,
      });
      await this.listCounters();
    },

    async handleCounterDeleted({ name }) {
      const response = await client.delete(`/counters/${name}`);
      await this.listCounters();
    },
  },
};
</script>

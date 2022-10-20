<template>
  <div>
    <div>
      <button @click="openModal" class="btn btn-primary">
        Create new counter
      </button>
    </div>

    <Modal v-show="isModalVisible" @close="closeModal">
      <template v-slot:content>
        <NewCounterForm @created="handleCounterCreated" />
      </template>
    </Modal>

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
      isModalVisible: false,
    };
  },
  methods: {
    async listCounters() {
      this.counter_metrics = null;
      const response = await client.get("/counters");
      this.counter_metrics = response.data;
    },

    async handleCounterCreated({ name, description, labelNames }) {
      let labels = [];
      if (labelNames.length != 0) {
        labels = labelNames.split(",");
      }

      await client.post("/counters", {
        name,
        description,
        labelNames: labels,
      });
      await this.listCounters();
      this.closeModal();
    },

    async handleCounterIncremented({ name, value = 1, labels }) {
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

    openModal() {
      console.log("Open modal");
      this.isModalVisible = true;
    },

    closeModal() {
      this.isModalVisible = false;
    },
  },
};
</script>

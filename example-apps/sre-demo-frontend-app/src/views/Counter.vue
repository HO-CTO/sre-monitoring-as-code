<template>
  <div>
    <div class="d-flex justify-content-end">
      <button @click="openModal(MODAL_CREATE_COUNTER)" class="btn btn-success">
        Create new counter
      </button>
    </div>

    <Modal v-show="isModalVisible" @close="closeModal" :error="error">
      <template v-slot:content>
        <NewCounterForm
          @created="handleCounterCreated"
          v-if="modalToDisplay === MODAL_CREATE_COUNTER"
        />
        <IncrementCounterForm
          :counter_name="counterName"
          @submitted="handleCounterIncremented"
          v-if="modalToDisplay === MODAL_INCREMENT_COUNTER"
        />
      </template>
    </Modal>

    <MetricTable
      v-if="counter_metrics"
      :metrics="counter_metrics"
      :supportedActions="supportedActions"
      metric-type="Counter"
      @actionClicked="handleIncrementButtonClicked"
      @metricDeleted="handleCounterDeleted"
    />
  </div>
</template>

<script setup>
import NewCounterForm from "../components/NewCounterForm.vue";
import IncrementCounterForm from "../components/IncrementCounterForm.vue";
import Modal from "../components/Modal.vue";

import { client } from "../utils/axios";
import { splitLabels } from "../utils/splitLabels";
import MetricTable from "../components/MetricTable.vue";
</script>

<script>
const MODAL_CREATE_COUNTER = "MODAL_CREATE_COUNTER";
const MODAL_INCREMENT_COUNTER = "MODAL_INCREMENT_COUNTER";

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
      modalToDisplay: "",
      counterName: "",
      error: "",
    };
  },
  methods: {
    async listCounters() {
      this.counter_metrics = null;
      const response = await client.get("/counters");
      this.counter_metrics = response.data;
      console.log({ metrics: this.counter_metrics });
    },

    async handleCounterCreated({ name, description, labelNames }) {
      this.error = "";
      try {
        await client.post("/counters", {
          name,
          description,
          labels: splitLabels(labelNames),
        });
        await this.listCounters();
        this.closeModal();
      } catch (e) {
        this.error = e?.response?.data?.error?.message || "";
      }
    },

    async handleCounterIncremented({ name, value = 1, labels }) {
      await client.post(`/counters/${name}/increment`, {
        value,
        labels: splitLabels(labels),
      });
      await this.listCounters();
      this.closeModal();
    },

    async handleCounterDeleted({ name }) {
      await client.delete(`/counters/${name}`);
      await this.listCounters();
    },

    openModal(modal) {
      this.modalToDisplay = modal;
      this.isModalVisible = true;
    },

    closeModal() {
      this.isModalVisible = false;
      this.error = "";
    },

    handleIncrementButtonClicked({ name }) {
      this.counterName = name;
      this.openModal(MODAL_INCREMENT_COUNTER);
    },
  },
};
</script>

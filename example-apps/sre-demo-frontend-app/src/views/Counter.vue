<template>
  <div>
    <div class="d-flex justify-content-end">
      <button @click="openModal(MODAL_CREATE_COUNTER)" class="btn btn-success">
        Create new counter
      </button>
    </div>

    <Modal v-show="isModalVisible" @close="closeModal">
      <template v-if="modalToDisplay === MODAL_CREATE_COUNTER" v-slot:content>
        <NewCounterForm @created="handleCounterCreated" />
      </template>
      <template
        v-if="modalToDisplay === MODAL_INCREMENT_COUNTER"
        v-slot:content
      >
        <IncrementCounterForm
          :counter_name="counterName"
          @submitted="handleCounterIncremented"
        />
      </template>
    </Modal>

    <CounterTable
      v-if="counter_metrics"
      :counterMetrics="counter_metrics"
      :supportedActions="supportedActions"
      @counterIncrementClicked="handleIncrementButtonClicked"
      @counterDeleted="handleCounterDeleted"
    />
  </div>
</template>

<script setup>
import NewCounterForm from "../components/NewCounterForm.vue";
import IncrementCounterForm from "../components/IncrementCounterForm.vue";
import CounterTable from "../components/CounterTable.vue";
import Modal from "../components/Modal.vue";

import { client } from "../utils/axios";
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
      let splitLabels = {};
      if (labels.length != 0) {
        let labelSplit = labels.split(",");
        for (let elem in labelSplit) {
          let elemSplit = labelSplit[elem].split("=");
          splitLabels[elemSplit[0]] = elemSplit[1];
        }
      }

      await client.post(`/counters/${name}/increment`, {
        value,
        labels: splitLabels,
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
    },

    handleIncrementButtonClicked({ name }) {
      this.counterName = name;
      this.openModal(MODAL_INCREMENT_COUNTER);
    },
  },
};
</script>

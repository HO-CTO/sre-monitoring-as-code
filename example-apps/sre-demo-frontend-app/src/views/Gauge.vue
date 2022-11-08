<template>
  <div>
    <div class="d-flex justify-content-end">
      <button @click="openModal(MODAL_CREATE_GAUGE)" class="btn btn-success">
        Create new gauge
      </button>
    </div>

    <Modal v-show="isModalVisible" @close="closeModal" :error="error">
      <template v-slot:content>
        <NewGaugeForm
          @created="handleGaugeCreated"
          v-if="modalToDisplay === MODAL_CREATE_GAUGE"
        />
        <IncDecGaugeForm
          :gauge_name="gaugeName"
          :gauge_option="gaugeOption"
          @submitted="handleGaugeAction"
          v-if="modalToDisplay === MODAL_INCDEC_GAUGE"
        />
      </template>
    </Modal>

    <MetricTable
      v-if="gauge_metrics"
      :metrics="gauge_metrics"
      :supportedActions="supportedActions"
      metric-type="Gauge"
      @actionClicked="handleActionButtonClicked"
      @metricDeleted="handleGaugeDeleted"
    />
  </div>
</template>

<script setup>
import NewGaugeForm from "../components/NewGaugeForm.vue";
import IncDecGaugeForm from "../components/IncDecGaugeForm.vue";
import MetricTable from "../components/MetricTable.vue";
import Modal from "../components/Modal.vue";

import { client } from "../utils/axios";
import { splitLabels } from "../utils/splitLabels";
</script>

<script>
const MODAL_CREATE_GAUGE = "MODAL_CREATE_GAUGE";
const MODAL_INCDEC_GAUGE = "MODAL_INCDEC_GAUGE";

export default {
  async mounted() {
    await this.listGauges();
  },
  data() {
    return {
      gauge_metrics: null,
      supportedActions: {
        increment: true,
        decrement: true,
        setValue: true,
        delete: true,
        observe: false,
      },
      isModalVisible: false,
      modalToDisplay: "",
      gaugeName: "",
      gaugeOption: "",
      error: "",
    };
  },
  methods: {
    async listGauges() {
      this.gauge_metrics = null;
      const response = await client.get("/gauges");
      this.gauge_metrics = response.data;
    },

    async handleGaugeCreated({ name, description, labelNames }) {
      this.error = "";
      try {
        await client.post("/gauges", {
          name,
          description,
          labels: splitLabels(labelNames),
        });
        await this.listGauges();
        this.closeModal();
      } catch (e) {
        this.error = e?.response?.data?.error?.message || "";
      }
    },

    async handleGaugeAction({ name, value = 1, labels }) {
      if (this.gaugeOption === "set") {
        await client.put(`/gauges/${name}/`, {
          value,
          labels: splitLabels(labels),
        });
      } else {
        await client.post(`/gauges/${name}/${this.gaugeOption}`, {
          value,
          labels: splitLabels(labels),
        });
      }
      await this.listGauges();
      this.closeModal();
    },

    async handleGaugeDeleted({ name }) {
      await client.delete(`/gauges/${name}`);
      await this.listGauges();
    },

    openModal(modal) {
      this.modalToDisplay = modal;
      this.isModalVisible = true;
    },

    closeModal() {
      this.isModalVisible = false;
      this.error = "";
    },

    handleActionButtonClicked({ name, action }) {
      this.gaugeName = name;
      this.gaugeOption = action;
      this.openModal(MODAL_INCDEC_GAUGE);
    },
  },
};
</script>

<template>
  <div>
    <div class="d-flex justify-content-end">
      <button @click="openModal(MODAL_CREATE_GAUGE)" class="btn btn-success">
        Create new gauge
      </button>
    </div>

    <Modal v-show="isModalVisible" @close="closeModal">
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

    <GaugeTable
      v-if="gauge_metrics"
      :gaugeMetrics="gauge_metrics"
      :supportedActions="supportedActions"
      @gaugeActionClicked="handleActionButtonClicked"
      @gaugeDeleted="handleGaugeDeleted"
    />
  </div>
</template>

<script setup>
import NewGaugeForm from "../components/NewGaugeForm.vue";
import IncDecGaugeForm from "../components/IncDecGaugeForm.vue";
import GaugeTable from "../components/GaugeTable.vue";
import Modal from "../components/Modal.vue";

import { client } from "../utils/axios";
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
    };
  },
  methods: {
    async listGauges() {
      this.gauge_metrics = null;
      const response = await client.get("/gauges");
      this.gauge_metrics = response.data;
    },

    async handleGaugeCreated({ name, description, labelNames }) {
      let splitLabels = {};
      if (labelNames.length != 0) {
        let labelSplit = labelNames.split(",");
        for (let elem in labelSplit) {
          let elemSplit = labelSplit[elem].split("=");
          splitLabels[elemSplit[0]] = elemSplit[1];
        }
      }

      await client.post("/gauges", {
        name,
        description,
        labels: splitLabels,
      });
      await this.listGauges();
      this.closeModal();
    },

    async handleGaugeAction({ name, value = 1, labels }) {
      let splitLabels = {};
      if (labels.length != 0) {
        let labelSplit = labels.split(",");
        for (let elem in labelSplit) {
          let elemSplit = labelSplit[elem].split("=");
          splitLabels[elemSplit[0]] = elemSplit[1];
        }
      }
      if (this.gaugeOption === "set") {
        await client.put(`/gauges/${name}/`, {
          value,
          labels: splitLabels,
        });
      } else {
        await client.post(`/gauges/${name}/${this.gaugeOption}`, {
          value,
          labels: splitLabels,
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
    },

    handleActionButtonClicked({ name, action }) {
      this.gaugeName = name;
      this.gaugeOption = action;
      this.openModal(MODAL_INCDEC_GAUGE);
    },
  },
};
</script>

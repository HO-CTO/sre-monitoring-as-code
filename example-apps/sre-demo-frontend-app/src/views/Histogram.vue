<template>
  <div>
    <div class="d-flex justify-content-end">
      <button @click="openModal(MODAL_CREATE_HISTOGRAM)" class="btn btn-success">
        Create new histogram
      </button>
    </div>

    <Modal v-show="isModalVisible" @close="closeModal">
      <template v-if="modalToDisplay === MODAL_CREATE_HISTOGRAM" v-slot:content>
        <NewHistogramForm @created="handleHistogramCreated" />
      </template>
      <template v-if="modalToDisplay === MODAL_OBSERVE_HISTOGRAM" v-slot:content>
        <ObserveHistogramForm
          :histogram_name="histogramName"
          :histogram_option="histogramOption"
          @submitted="handleHistogramAction"
        />
      </template>
    </Modal>

    <HistogramTable
      v-if="histogram_metrics"
      :histogramMetrics="histogram_metrics"
      :supportedActions="supportedActions"
      @histogramActionClicked="handleActionButtonClicked"
      @histogramDeleted="handleHistogramDeleted"
    />
  </div>
</template>

<script setup>
import NewHistogramForm from "../components/NewHistogramForm.vue";
import HistogramTable from "../components/HistogramTable.vue";
import Modal from "../components/Modal.vue";

import { client } from "../utils/axios";
import ObserveHistogramForm from "../components/ObserveHistogramForm.vue";
</script>

<script>
const MODAL_CREATE_HISTOGRAM = "MODAL_CREATE_HISTOGRAM";
const MODAL_OBSERVE_HISTOGRAM = "MODAL_OBSERVE_HISTOGRAM";

export default {
  async mounted() {
    await this.listHistograms();
  },
  data() {
    return {
      histogram_metrics: null,
      supportedActions: {
        increment: false,
        decrement: false,
        setValue: false,
        delete: true,
        observe: true,
      },
      isModalVisible: false,
      modalToDisplay: "",
      histogramName: "",
      histogramOption: "",
    };
  },
  methods: {
    async listHistograms() {
      this.histogram_metrics = null;
      const response = await client.get("/histograms");
      this.histogram_metrics = response.data;
    },

    async handleHistogramCreated({ name, description, labelNames }) {
      let labels = [];
      if (labelNames.length != 0) {
        labels = labelNames.split(",");
      }

      await client.post("/histograms", {
        name,
        description,
        labelNames: labels,
      });
      await this.listHistograms();
      this.closeModal();
    },

    async handleHistogramAction({ name, value = 1, labels }) {
      let splitLabels = {};
      if (labels.length != 0) {
        let labelSplit = labels.split(",");
        for (let elem in labelSplit) {
          let elemSplit = labelSplit[elem].split("=");
          splitLabels[elemSplit[0]] = elemSplit[1];
        }
      }
      if (this.histogramOption === "set") {
        await client.put(`/histograms/${name}/`, {
          value,
          labels: splitLabels,
        });
      } else {
        await client.post(`/histograms/${name}/${this.histogramOption}`, {
          value,
          labels: splitLabels,
        });
      }
      await this.listHistograms();
      this.closeModal();
    },

    async handleHistogramDeleted({ name }) {
      await client.delete(`/histograms/${name}`);
      await this.listHistograms();
    },

    openModal(modal) {
      this.modalToDisplay = modal;
      this.isModalVisible = true;
    },

    closeModal() {
      this.isModalVisible = false;
    },

    handleActionButtonClicked({ name, action }) {
      console.log({name, action})
      this.histogramName = name;
      this.histogramOption = action;
      this.openModal(MODAL_OBSERVE_HISTOGRAM);
    },
  },
};
</script>

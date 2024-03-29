<template>
  <div>
    <div class="d-flex justify-content-end">
      <button
        @click="openModal(MODAL_CREATE_HISTOGRAM)"
        class="btn btn-success"
      >
        Create new histogram
      </button>
    </div>

    <Modal v-show="isModalVisible" @close="closeModal" :error="error">
      <template v-slot:content>
        <NewHistogramForm
          @created="handleHistogramCreated"
          v-if="modalToDisplay === MODAL_CREATE_HISTOGRAM"
        />
        <ObserveHistogramForm
          :histogram_name="histogramName"
          :histogram_option="histogramOption"
          @submitted="handleHistogramAction"
          v-if="modalToDisplay === MODAL_OBSERVE_HISTOGRAM"
        />
      </template>
    </Modal>

    <MetricTable
      v-if="histogram_metrics"
      :metrics="histogram_metrics"
      :supportedActions="supportedActions"
      metric-type="Histogram"
      @actionClicked="handleActionButtonClicked"
      @metricDeleted="handleHistogramDeleted"
    />
  </div>
</template>

<script setup>
import NewHistogramForm from "../components/NewHistogramForm.vue";
import MetricTable from "../components/MetricTable.vue";
import Modal from "../components/Modal.vue";

import { client } from "../utils/axios";
import { splitLabels } from "../utils/splitLabels";
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
      error: "",
    };
  },
  methods: {
    async listHistograms() {
      this.histogram_metrics = null;
      const response = await client.get("/histograms");
      this.histogram_metrics = response.data;
    },

    async handleHistogramCreated({
      name,
      description,
      labelNames,
      bucketsList,
    }) {
      this.error = "";
      let buckets = [];
      if (bucketsList && bucketsList.length !== 0) {
        buckets = bucketsList.split(",");
        buckets = buckets.map(Number);
      }

      try {
        await client.post("/histograms", {
          name,
          description,
          labels: splitLabels(labelNames),
          buckets,
        });
        await this.listHistograms();
        this.closeModal();
      } catch (e) {
        this.error = e?.response?.data?.error?.message || "";
      }
    },

    async handleHistogramAction({ name, value = 1, labels }) {
      if (this.histogramOption === "set") {
        await client.put(`/histograms/${name}/`, {
          value,
          labels: splitLabels(labels),
        });
      } else {
        await client.post(`/histograms/${name}/${this.histogramOption}`, {
          value,
          labels: splitLabels(labels),
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
      this.error = "";
    },

    handleActionButtonClicked({ name, action }) {
      this.histogramName = name;
      this.histogramOption = action;
      this.openModal(MODAL_OBSERVE_HISTOGRAM);
    },
  },
};
</script>

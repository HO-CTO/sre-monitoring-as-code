<template>
  <div>
    <h3>Histogram metrics</h3>
    <div class="container">
      <div class="container" v-if="data.length == 0">
        <p>No metrics to display...</p>
      </div>
      <div v-else>
        <div>
          <table class="table">
            <thead>
              <tr>
                <th>Histogram Name</th>
                <th>Labels</th>
                <th>Value</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody v-for="(histogram, index) in data" :key="index">
              <tr v-if="histogram.value.length == 0">
                <td>{{ histogram.name }}</td>
                <td>no labels</td>
                <td>no value</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @observeClicked="
                      onActionClicked({
                        name: histogram.name,
                        action: 'observe',
                      })
                    "
                    @deleteClicked="this.onDeleteClicked()"
                  />
                </td>
              </tr>
              <tr
                v-else
                v-for="(valueElem, index2) in histogram.value"
                :key="index2"
              >
                <td>{{ valueElem.name }}</td>
                <td>{{ valueElem.labels }}</td>
                <td>{{ valueElem.value }}</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @observeClicked="
                      onActionClicked({
                        name: histogram.name,
                        action: 'observe',
                      })
                    "
                    @deleteClicked="this.onDeleteClicked(histogram.name)"
                  />

                  <Modal
                    v-show="this.displayDeleteConfirm"
                    @close="handleDeleteCancel"
                  >
                    <template v-slot:content>
                      <ConfirmDialog
                        @submit="handleDeleteConfirm(histogram.name)"
                        @cancel="handleDeleteCancel"
                      >
                        <template v-slot:title>
                          Delete metric "{{ histogram.name }}"?
                        </template>
                        <template v-slot:message>
                          All instances of the metric named "{{
                            histogram.name
                          }}" will be deleted.
                        </template>
                        <template v-slot:submitButtonText>
                          Yes, delete.
                        </template>
                        <template v-slot:submitButtonClass>
                          btn-danger
                        </template>
                      </ConfirmDialog>
                    </template>
                  </Modal>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ActionButtons from "./ActionButtons.vue";
import ConfirmDialog from "./ConfirmDialog.vue";
import Modal from "./Modal.vue";
export default {
  props: ["supportedActions", "histogramMetrics"],
  data() {
    return {
      data: this.histogramMetrics,
      displayDeleteConfirm: false,
    };
  },
  methods: {
    onActionClicked({ name, action }) {
      this.$emit("histogramActionClicked", { name, action });
    },

    onDeleteClicked() {
      this.displayDeleteConfirm = true;
    },

    handleDeleteConfirm(name) {
      this.$emit("histogramDeleted", { name });
      this.displayDeleteConfirm = false;
    },

    handleDeleteCancel() {
      this.displayDeleteConfirm = false;
    },
  },
  components: { ActionButtons, ConfirmDialog, Modal },
};
</script>

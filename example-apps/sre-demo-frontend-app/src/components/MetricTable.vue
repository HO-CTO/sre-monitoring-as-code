<template>
  <div>
    <h3>{{ this.metricType }} metrics</h3>
    <div class="container">
      <div class="container" v-if="data.length === 0">
        <p>No {{ this.metricType }} metrics to display...</p>
      </div>
      <div v-else>
        <div>
          <table class="table">
            <thead>
              <tr>
                <th>{{ this.metricType }} Name</th>
                <th>Labels</th>
                <th>Value</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody v-for="(metric, index) in data" :key="index">
              <tr v-if="metric.value.length === 0">
                <td>{{ metric.name }}</td>
                <td>no labels</td>
                <td>no value</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @incrementClicked="
                      onActionClicked({
                        name: metric.name,
                        action: 'increment',
                      })
                    "
                    @decrementClicked="
                      onActionClicked({
                        name: metric.name,
                        action: 'decrement',
                      })
                    "
                    @setValueClicked="
                      onActionClicked({ name: metric.name, action: 'set' })
                    "
                    @observeClicked="
                      onActionClicked({
                        name: metric.name,
                        action: 'observe',
                      })
                    "
                    @deleteClicked="this.onDeleteClicked()"
                  />
                </td>
              </tr>
              <tr
                v-else
                v-for="(metricValue, index2) in metric.value"
                :key="index2"
              >
                <td>{{ metricValue.name || metric.name }}</td>
                <td>{{ metricValue.labels }}</td>
                <td>{{ metricValue.value }}</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @incrementClicked="
                      onActionClicked({
                        name: metric.name,
                        action: 'increment',
                      })
                    "
                    @decrementClicked="
                      onActionClicked({
                        name: metric.name,
                        action: 'decrement',
                      })
                    "
                    @setValueClicked="
                      onActionClicked({ name: metric.name, action: 'set' })
                    "
                    @observeClicked="
                      onActionClicked({
                        name: metric.name,
                        action: 'observe',
                      })
                    "
                    @deleteClicked="this.onDeleteClicked(metric.name)"
                  />
                  <Modal
                    v-show="this.displayDeleteConfirm"
                    @close="handleDeleteCancel"
                  >
                    <template v-slot:content>
                      <ConfirmDialog
                        @submit="handleDeleteConfirm(metric.name)"
                        @cancel="handleDeleteCancel"
                      >
                        <template v-slot:title>
                          Delete metric "{{ metric.name }}"?
                        </template>
                        <template v-slot:message>
                          All instances of the metric named "{{ metric.name }}"
                          will be deleted.
                        </template>
                        <template v-slot:submitButtonText>
                          Yes, delete.
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
  props: ["supportedActions", "metrics", "metricType"],
  data() {
    return {
      data: this.metrics,
      displayDeleteConfirm: false,
    };
  },
  methods: {
    onActionClicked({ name, action }) {
      this.$emit("actionClicked", { name, action });
    },

    onDeleteClicked() {
      this.displayDeleteConfirm = true;
    },

    handleDeleteConfirm(name) {
      this.$emit("metricDeleted", { name });
      this.displayDeleteConfirm = false;
    },

    handleDeleteCancel() {
      this.displayDeleteConfirm = false;
    },
  },
  components: { ActionButtons, ConfirmDialog, Modal },
};
</script>

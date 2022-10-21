<template>
  <div>
    <h3>Gauge metrics</h3>
    <div class="container">
      <div class="container" v-if="data.length == 0">
        <p>No metrics to display...</p>
      </div>
      <div v-else>
        <div>
          <table class="table">
            <thead>
              <tr>
                <th>Gauge Name</th>
                <th>Labels</th>
                <th>Value</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody v-for="(gauge, index) in data" :key="index">
              <tr v-if="gauge.value.length == 0">
                <td>{{ gauge.name }}</td>
                <td>no labels</td>
                <td>no value</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @incrementClicked="
                      onActionClicked({ name: gauge.name, action: 'increment' })
                    "
                    @decrementClicked="
                      onActionClicked({ name: gauge.name, action: 'decrement' })
                    "
                    @setValueClicked="
                      onActionClicked({ name: gauge.name, action: 'set' })
                    "
                    @deleteClicked="this.onDeleteClicked()"
                  />
                </td>
              </tr>
              <tr
                v-else
                v-for="(valueElem, index2) in gauge.value"
                :key="index2"
              >
                <td>{{ gauge.name }}</td>
                <td>{{ valueElem.labels }}</td>
                <td>{{ valueElem.value }}</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @incrementClicked="
                      onActionClicked({ name: gauge.name, action: 'increment' })
                    "
                    @decrementClicked="
                      onActionClicked({ name: gauge.name, action: 'decrement' })
                    "
                    @setValueClicked="
                      onActionClicked({ name: gauge.name, action: 'set' })
                    "
                    @deleteClicked="this.onDeleteClicked(gauge.name)"
                  />

                  <Modal
                    v-show="this.displayDeleteConfirm"
                    @close="handleDeleteCancel"
                  >
                    <template v-slot:content>
                      <ConfirmDialog
                        @submit="handleDeleteConfirm(gauge.name)"
                        @cancel="handleDeleteCancel"
                      >
                        <template v-slot:title>
                          Delete metric "{{ gauge.name }}"?
                        </template>
                        <template v-slot:message>
                          All instances of the metric named "{{ gauge.name }}"
                          will be deleted.
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
  props: ["supportedActions", "gaugeMetrics"],
  data() {
    return {
      data: this.gaugeMetrics,
      displayDeleteConfirm: false,
    };
  },
  methods: {
    onActionClicked({ name, action }) {
      this.$emit("gaugeActionClicked", { name, action });
    },

    onDeleteClicked() {
      this.displayDeleteConfirm = true;
    },

    handleDeleteConfirm(name) {
      this.$emit("gaugeDeleted", { name });
      this.displayDeleteConfirm = false;
    },

    handleDeleteCancel() {
      this.displayDeleteConfirm = false;
    },
  },
  components: { ActionButtons, ConfirmDialog, Modal },
};
</script>

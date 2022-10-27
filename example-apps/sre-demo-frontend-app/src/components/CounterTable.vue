<template>
  <div>
    <h3>Counter metrics</h3>
    <div class="container">
      <div class="container" v-if="data.length == 0">
        <p>No metrics to display...</p>
      </div>
      <div v-else>
        <div>
          <table class="table">
            <thead>
              <tr>
                <th>Counter Name</th>
                <th>Labels</th>
                <th>Value</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody v-for="(counter, index) in data" :key="index">
              <tr v-if="counter.value.length == 0">
                <td>{{ counter.name }}</td>
                <td>no labels</td>
                <td>no value</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @incrementClicked="
                      this.onIncrementClicked({ name: counter.name })
                    "
                    @deleteClicked="this.onDeleteClicked()"
                  />
                </td>
              </tr>
              <tr
                v-else
                v-for="(valueElem, index2) in counter.value"
                :key="index2"
              >
                <td>{{ counter.name }}</td>
                <td>{{ valueElem.labels }}</td>
                <td>{{ valueElem.value }}</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @incrementClicked="
                      this.onIncrementClicked({ name: counter.name })
                    "
                    @deleteClicked="this.onDeleteClicked(counter.name)"
                  />
                  <Modal
                    v-show="this.displayDeleteConfirm"
                    @close="handleDeleteCancel"
                  >
                    <template v-slot:content>
                      <ConfirmDialog
                        @submit="handleDeleteConfirm(counter.name)"
                        @cancel="handleDeleteCancel"
                      >
                        <template v-slot:title>
                          Delete metric "{{ counter.name }}"?
                        </template>
                        <template v-slot:message>
                          All instances of the metric named "{{ counter.name }}"
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
  props: ["supportedActions", "counterMetrics"],
  data() {
    return {
      data: this.counterMetrics,
      displayDeleteConfirm: false,
    };
  },
  methods: {
    async onIncrementClicked({ name }) {
      this.$emit("counterIncrementClicked", { name });
    },
    async onDeleteClicked() {
      this.displayDeleteConfirm = true;
    },

    handleDeleteConfirm(name) {
      this.$emit("counterDeleted", { name });
      this.displayDeleteConfirm = false;
    },

    handleDeleteCancel() {
      this.displayDeleteConfirm = false;
    },
  },
  components: { ActionButtons, ConfirmDialog, Modal },
};
</script>

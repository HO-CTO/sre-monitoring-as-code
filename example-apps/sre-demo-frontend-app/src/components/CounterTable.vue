<template>
  <div>
    <h3>Counter metric</h3>
    <div class="container">
      <div class="container" v-if="data.length == 0">
        <p>Its empty</p>
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
                      this.onIncrementClicked({ name: counter.name, value: 1 })
                    "
                    @deleteClicked="this.onDeleteClicked(counter.name)"
                  />
                </td>
              </tr>
              <tr v-else v-for="valueElem in counter.value">
                <td>{{ counter.name }}</td>
                <td>{{ valueElem.labels }}</td>
                <td>{{ valueElem.value }}</td>
                <td>
                  <ActionButtons
                    :supportedActions="this.supportedActions"
                    @incrementClicked="
                      this.onIncrementClicked({
                        name: counter.name,
                        value: 1,
                        labels: valueElem.labels,
                      })
                    "
                    @deleteClicked="this.onDeleteClicked(counter.name)"
                  />
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
export default {
  props: ["supportedActions", "counterMetrics"],
  data() {
    return {
      data: this.counterMetrics,
    };
  },
  methods: {
    async onIncrementClicked(payload) {
      this.$emit("counterIncremented", payload);
    },
    async onDeleteClicked(name) {
      this.$emit("counterDeleted", { name });
    },
  },
  components: { ActionButtons },
};
</script>

<template>
  <div>
    <h3>Create new counter</h3>
    <div>
      <div class="form-group">
        <label for="counterName">Counter Name</label>
        <input
          class="form-control"
          id="counterName"
          type="text"
          v-model="createCounterName"
        />
      </div>
      <div class="form-group">
        <label for="counterDesc">Counter Desc</label>
        <input
          class="form-control"
          id="counterDesc"
          type="text"
          v-model="createCounterDesc"
        />
      </div>
      <div class="form-group">
        <label for="counterLabels">Counter labels</label>
        <input
          class="form-control"
          id="counterLabels"
          type="text"
          v-model="createCounterLabels"
        />
      </div>
      <button class="btn btn-primary" type="button" @click="createCounter">
        Create new counter
      </button>
    </div>
  </div>
</template>

<script>
export default {};
</script>

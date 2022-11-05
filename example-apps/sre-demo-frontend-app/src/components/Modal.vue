<template>
  <div class="fullScreenModal" tabindex="-1" role="dialog">
    <div role="document">
      <div>
        <div class="d-flex justify-content-end">
          <button @click="$emit('close')" role="button" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div v-if="error !== ''" class="alert alert-danger mt-5" role="alert">
          <h4 class="alert-heading">Error</h4>
          {{ error }}.
        </div>
        <slot name="content"></slot>
        <div class="text-right mt-20"></div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ["error"],
};
</script>

<style>
.fullScreenModal {
  width: 100%;
  height: 100vh;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>

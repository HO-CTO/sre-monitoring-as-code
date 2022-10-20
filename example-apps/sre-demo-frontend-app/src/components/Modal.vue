<template>
  <div class="fullScreenModal" tabindex="-1" role="dialog">
    <div role="document">
      <div>
        <div class="d-flex align-items-end">
          <button @click="$emit('close')" role="button" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <slot name="content"></slot>
        <div class="text-right mt-20">
          <!-- <button @click="$emit('close')" class="btn mr-5" role="button">
            Close
          </button> -->
        </div>
      </div>
    </div>
  </div>
</template>

<style>
.fullScreenModal {
  width: 100%;
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

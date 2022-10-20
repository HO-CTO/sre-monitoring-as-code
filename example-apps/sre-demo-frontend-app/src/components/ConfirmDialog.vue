<template>
  <div>
    <h3>
      <slot name="title">Are you sure?</slot>
    </h3>
    <p>
      <slot name="message">Do you want to proceed?</slot>
    </p>
    <div>
      <button @click="$emit('cancel')">
        <slot name="cancelButtonText">Cancel</slot>
      </button>
      <button @click="$emit('submit')">
        <slot name="submitButtonText">Submit</slot>
      </button>
    </div>
  </div>
</template>

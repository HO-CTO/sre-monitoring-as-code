<template>
  <div>
    <button
      @click="$emit('incrementClicked')"
      v-if="supportedActions.increment"
    >
      ⬆️
    </button>
    <button
      @click="$emit('decrementClicked')"
      v-if="supportedActions.decrement"
    >
      ⬇️
    </button>
    <button @click="$emit('setValueClicked')" v-if="supportedActions.setValue">
      🔢
    </button>
    <button @click="$emit('observeClicked')" v-if="supportedActions.observe">
      🔎
    </button>
    <button @click="$emit('deleteClicked')" v-if="supportedActions.delete">
      🗑️
    </button>
  </div>
</template>

<script>
export default {
  props: ["supportedActions"],
  emits: [
    "incrementClicked",
    "decrementClicked",
    "setValueClicked",
    "deleteClicked",
    "observeClicked",
  ],
};
</script>

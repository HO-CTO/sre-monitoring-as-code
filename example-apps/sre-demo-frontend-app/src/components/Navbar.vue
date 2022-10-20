<template>
  <nav class="p-10">
    <div class="d-flex justify-content-between">
      <div class="d-flex">
        <div class="pr-10">
          <router-link to="/">Home</router-link>
        </div>
        <div class="pr-10">
          <router-link to="/counter">Counter</router-link>
        </div>
        <div class="pr-10"><router-link to="/gauge">Gauges</router-link></div>
        <div class="pr-10">
          <router-link to="/histograms">Histograms</router-link>
        </div>
      </div>
      <div>
        <Version />
      </div>
    </div>
  </nav>
</template>

<script setup>
import Version from "./Version.vue";
</script>

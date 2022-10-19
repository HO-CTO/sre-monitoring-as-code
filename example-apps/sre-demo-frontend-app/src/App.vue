<template>
  <main class="flex">
    <div>
      <p>
        <!-- use the router-link component for navigation. -->
        <!-- specify the link by passing the `to` prop. -->
        <!-- `<router-link>` will render an `<a>` tag with the correct `href` attribute -->
        <router-link to="/">Go to Home</router-link>
        <router-link to="/counter">Go to Counter</router-link>
        <router-link to="/gauge">Go to Gauge</router-link>
      </p>
      <!-- route outlet -->
      <!-- component matched by the route will render here -->
      <Version />
      <router-view></router-view>
    </div>
  </main>
</template>

<script setup>
import Version from "./components/Version.vue";
</script>

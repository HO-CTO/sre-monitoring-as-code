<template>
  <main class="font-size-12">
    <div>
      <p>
        <!-- use the router-link component for navigation. -->
        <!-- specify the link by passing the `to` prop. -->
        <!-- `<router-link>` will render an `<a>` tag with the correct `href` attribute -->
        <Navbar />
      </p>
      <!-- route outlet -->
      <!-- component matched by the route will render here -->
      <div class="page-wrapper">
        <div class="content-wrapper">
          <div class="container">
            <router-view></router-view>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import Navbar from "./components/Navbar.vue";
</script>

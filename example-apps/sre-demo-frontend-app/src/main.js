import { createApp } from "vue";
import { createRouter, createWebHashHistory } from "vue-router";
import { VueQueryPlugin } from "vue-query";
import App from "./App.vue";

import "./assets/main.css";

import Home from "./views/Home.vue";
import Counter from "./views/Counter.vue";
import Gauge from "./views/Gauge.vue";
import Histogram from "./views/Histogram.vue";

// 2. Define some routes
// Each route should map to a component.
// We'll talk about nested routes later.
const routes = [
  { path: "/", component: Home },
  { path: "/counter", component: Counter },
  { path: "/gauge", component: Gauge },
  { path: "/histogram", component: Histogram },
];

// 3. Create the router instance and pass the `routes` option
// You can pass in additional options here, but let's
// keep it simple for now.
const router = createRouter({
  // 4. Provide the history implementation to use. We are using the hash history for simplicity here.
  history: createWebHashHistory(),
  routes, // short for `routes: routes`
});

// 5. Create and mount the root instance.
const app = createApp(App);
// Make sure to _use_ the router instance to make the
// whole app router-aware.
app.use(router);
app.use(VueQueryPlugin);

app.mount("#app");

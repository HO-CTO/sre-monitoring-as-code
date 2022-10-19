<template>
    {{`API Version: ${version.runtime} ${version.version}`}}
</template>

<script>
const baseApiUrl = "http://localhost:4001";

const headers = {
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json",
};

const initialValues = {
    version: {
        runtime: "?",
        version: "?",
    }
};

export default {
  mounted() {
    fetch(`${baseApiUrl}/version`, {
      mode: "cors",
      headers,
    })
      .then((data) => data.json())
      .then((data) => {
        this.version = data
      });
  },
  data() {
    return {...initialValues};
  }
};
</script>
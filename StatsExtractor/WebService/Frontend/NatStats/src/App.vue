<template>
  <MainPage/>
</template>

<script>

import MainPage from "./components/MainPage.vue"
import "@fontsource/ubuntu";

export default {
  name: 'App',
  components: {
    MainPage
  }
}
</script>

<style>
#app {
  font-family: Ubuntu;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

body {
  overflow: hidden;
}

</style>

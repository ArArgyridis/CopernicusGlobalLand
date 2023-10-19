//css


import 'bootstrap/dist/css/bootstrap.min.css';
//import 'bootstrap';

import { createApp } from 'vue';


import App from './App.vue';
import store from "./store.js";


const app = createApp(App);
app.use(store.buildStore());
app.mount('#app')

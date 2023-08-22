<template>
	<time class="icon">
		<em>{{dayName}}</em>
		<strong>{{month}} {{year}}</strong>
		<span>{{day}}</span>
	</time>
</template>

<script>
export default {
	name: "Dashboard",
	props: {
		date: {
			type: Date,
			default: new Date()
		}
	},
	computed: {
		day() {
			return this.date.getDate();
		},
		dayName() {
			return this.weekday[this.date.getDay()];
		},
		month() {
			return this.date.toLocaleString('default', { month: 'short' });
		},
		year() {
			return this.date.getFullYear();
		}
	},
	data() {
		return {
			weekday: ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
		}
	}
}

</script>

<style scoped>
time.icon
{
  font-size: 1em; /* change icon size */
  display: block;
  position: relative;
  width: 7em;
  height: 7em;
  background-color: #fff;
  border-radius: 0.6em;
  box-shadow: 0 1px 0 #bdbdbd, 0 2px 0 #fff, 0 3px 0 #bdbdbd, 0 4px 0 #fff, 0 5px 0 #bdbdbd, 0 0 0 1px #bdbdbd;
  overflow: hidden;
}

time.icon *
{
  display: block;
  width: 100%;
  font-size: 1em;
  font-weight: bold;
  font-style: normal;
  text-align: center;
}

time.icon strong
{
  position: absolute;
  top: 0;
  padding: 0.4em 0;
  color: #fff;
  background-color: #F00000;
  border-bottom: 1px dashed #f37302;
  box-shadow: 0 2px 0 #F00000;
}

time.icon em
{
  position: absolute;
  bottom: 0.3em;
  color: #F00000;
}

time.icon span
{
  font-size: 2.8em;
  letter-spacing: -0.05em;
  padding-top: 0.8em;
  color: #2f2f2f;
}

</style>

export default {
	endpointURL: process.env.NODE_ENV == "development" ? "http://192.168.2.2/endpoint" : "http://185.213.74.224/endpoint",
	wmsURL: process.env.NODE_ENV == "development" ? "http://192.168.2.2/wms/" : "http://185.213.74.224/mapcache",
} 

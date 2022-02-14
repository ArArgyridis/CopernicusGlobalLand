export default {
	endpointURL: process.env.NODE_ENV == "development" ? "http://localhost/endpoint" : "http://185.213.74.224/endpoint",
	wmsURL: process.env.NODE_ENV == "development" ? "http://localhost/wms/" : "http://185.213.74.224/mapcache",
} 

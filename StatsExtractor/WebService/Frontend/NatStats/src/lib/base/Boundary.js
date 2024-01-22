export class Boundary {
	constructor(boundary, maxZoom = 14, layerId = null, selectedPolygonId = null) {
		this.id = undefined;
		this.description = undefined;
		this.url = undefined;
		Object.assign(this, boundary);
		this.maxZoom = maxZoom;
		this.layerId = layerId;
		this.selectedPolygonId = selectedPolygonId;
	}
} 

"""
   Copyright (C) 2021  Argyros Argyridis arargyridis at gmail dot com
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import mapscript, os
from datetime import datetime
from osgeo import osr
class LayerInfo(object):
	def __init__(self, processFile, layerName, epsgStr, width, height, extent, date=None, productKey=None, style=None):
		self.processFile = processFile
		self.layerName = layerName
		self.epsgStr = epsgStr
		self.width = width
		self.height = height
		self.extent = extent
		self.style = style
		self.date = date
		self.productKey = productKey


class MapServer:
	
	def __init__(self, layerInfoList, wmsServerURL, outMapFile = "mapserver.map", wmsTitle = "A TEMP NAME",
				 projection = None, extent = None):
		self._layerInfoList = layerInfoList
		self._wmsServerURL = wmsServerURL
		self._outMapFile = outMapFile
		self._wmsTitle = wmsTitle
		self._projection = projection

		if self._projection is None:
			self._projection = self._layerInfoList[0].epsgStr


		ss = osr.SpatialReference()
		ss.ImportFromEPSG(int(self._projection.split(":")[1]))
		unit = ss.GetAttrValue("UNIT")
		if unit == "degree":
			self._units = mapscript.MS_DD
		elif unit == "metre":
			self._units = mapscript.MS_METERS

		self._extent = extent
		if self._extent is None:
			self._extent = self._layerInfoList[0].extent


	def process(self):
		imageryMap = mapscript.mapObj()
		imageryMap.web.metadata.set("wms_onlineresource", self._wmsServerURL)
		imageryMap.web.metadata.set("wms_enable_request", "*")

		imageryMap.name = self._wmsTitle
		imageryMap.setSize(256, 256)
		imageryMap.maxsize = 256
		imageryMap.setProjection(self._projection)
		imageryMap.setExtent(*self._extent)

		outputFormat = mapscript.outputFormatObj("GD/JPEG")
		imageryMap.setOutputFormat(outputFormat)

		inPath = os.path.split(self._layerInfoList[0].processFile)[0]

		#building tile index
		#tileIndex = os.path.join(inPath, "tileindex.shp")
		#cmd = "gdaltindex {0} index_file {1}".format(tileIndex, processFile)
		#os.system(cmd)

		for layerInfo in self._layerInfoList:
			inFileName = os.path.splitext(layerInfo.processFile.split("/")[-1])[0]

			layer = mapscript.layerObj()
			imageryMap.web.metadata.set("wms_title", self._wmsTitle)
			imageryMap.web.metadata.set("wms_srs", layerInfo.epsgStr)

			layer.data =layerInfo.processFile
			layer.name = layerInfo.layerName
			layer.type = mapscript.MS_LAYER_RASTER
			if isinstance(layerInfo.style, list):
				for style in layerInfo.style:
					layer.addProcessing("SCALE_{0}={1},{2}".format(style[0], style[1], style[2]) )

			layer.setProjection(layerInfo.epsgStr)
			layer.units = self._units
			layer.metadata.set("wms_srs", layerInfo.epsgStr)
			layer.metadata.set("STATUS", "ON")
			if layerInfo.date != None:
				layer.metadata.set("wms_timedefault", datetime.strptime(layerInfo.date, "%Y-%m-%d").isoformat())
				layer.metadata.set("wms_timeextent", layerInfo.date+"/"+layerInfo.date)
				layer.metadata.set("wms_timeitem", "TIME")
			#layer.tileindex = tileIndex
			imageryMap.insertLayer(layer)
			
		os.makedirs(os.path.split(self._outMapFile)[0],exist_ok=True)

		imageryMap.save(self._outMapFile)
		imageryMap = None
		
	def getInfo(self):
		return (self._outMapFile, self.__wmsURL)
		
		
		
	

	

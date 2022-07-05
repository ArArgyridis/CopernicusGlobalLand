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

import os, sys, threading
from time import sleep
from StatsExtractor.Backend.DataCrawler import DataCrawler
from StatsExtractor.Backend.ZonalStatsExtractor import ZonalStatsExtractor
from StatsExtractor.Backend.MapserverImporter import MapserverImporter
from AnomalyDetectors.LongTermComparisonAnomalyDetector import run as runLongTermComparisonAnomalyDetector
from Libs.Constants import Constants
from Libs.ConfigurationParser import ConfigurationParser

def main():
	if len(sys.argv) < 2:
		print("usage: python main.py config_file")
		return 1
	
	config = sys.argv[1]
	# loading constants
	Constants.load(config)

	cfg = ConfigurationParser(config)
	
	if cfg.parse() != 1:
		while True:
			for pid in Constants.PRODUCT_INFO:
				inDir = cfg.filesystem.imageryPath
				if Constants.PRODUCT_INFO[pid].productType == "anomaly":
					inDir = cfg.filesystem.anomalyProductsPath
					tmpDir = os.path.join(inDir, Constants.PRODUCT_INFO[pid].productNames[0])
					os.makedirs(tmpDir, exist_ok=True)

				obj = DataCrawler(cfg, Constants.PRODUCT_INFO[pid], False)

				obj.importProductFromLocalStorage(inDir)
				#obj.fetchProductFromVITO(dir="/home/argyros/Desktop/data/BIOPAR/", storageDir=cfg.filesystem.imageryPath)
				#compute anomalies
				#if Constants.PRODUCT_INFO[pid].productType == "anomaly":
				#	print("Computing anomalies!")
				#	runLongTermComparisonAnomalyDetector(pid, config)

				mapserver = MapserverImporter(config)
				mapserver.process()

			#fetching stratifications and compute stats for each strata
			query = "select description from stratification s "
			print("Extracting statistics")
			res = cfg.pgConnections[cfg.statsInfo.connectionId].fetchQueryResult(query)
			if res != 1:
				for row in res:
					obj = ZonalStatsExtractor(row[0], config)
					obj.process(productIds=[ Constants.PRODUCT_INFO[pid].id for pid in Constants.PRODUCT_INFO])

			print("process completed! Waiting....")
			sleep(43200)
			#sleep(1)
	
	return 0
	
	
if __name__ == "__main__":
	main()

NOTE: When executing scripts, the current directory should be the same with the directory where the script is located for the imports to work properly (need to be refined)
Steps:
- Create a configuration file (check existing config.json). It is mandatory that an "admin" connection is defined in the pg_connections section
- Run Backend/DBDeployer.py e.g.
	python DBDeployer.py ../config.json ../schema.sql.template
  
- Run Backend/DBImporter.py e.g.
	python "../data/Vector/ref-countries-2020-01m.shp/CNTR_RG_01M_2020_4326.shp/fixed.shp" fixed countries ../config.json  
  
NOTE 1: first parameter is the shapefile to import, second the temporary name of the shapefile inside DB, third an identifier for the stratification and fourth the configuration file. This populates the stratification table.
NOTE 2: currently only 2 products are created from the system, more to come.
  
- Run Backend/StatsExtractor.py e.g. 
	python StatsExtractor.py "../data/Imagery/" ../config.json countries
 

import re

class Constants:
    PRODUCT_INFO = {
        "NDVI300GLOBEV2": {
            "PATTERN": "c_gls_NDVI300_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})_GLOBE_OLCI_V2.0.1.nc",
            "TYPES": (int, int, int, int, int,),
            "CREATE_DATE": lambda ptr: "{0}-{1}-{2}T{3}:{4}:00".format(*ptr),
            "VARIABLE": "NDVI"
        }
    }


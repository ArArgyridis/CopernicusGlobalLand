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

import sys,json
sys.path.extend(['../'])

class GenericRequest(object):
    def __init__(self, cfg="../config.json", cfgParser=None, requestData=None):
        self._config = cfgParser(cfg)
        self._requestData = requestData

    def process(self):
        request = "undefined"
        status = "200 OK"
        ret = None
        try:
            self._config.parse()
            if self._requestData is None:
                raise SystemError
            elif "request" in self._requestData:
                ret = self._processRequest()
            else:
                raise SystemError

            if ret == 1:
                raise SystemError

        except:
            status = "422 Unprocessable Entity"
            ret = {"error": "Unable to process. Verify that input parameters are appropriate and try again"}


        return (status, ret)

    def _processRequest(self):
        print("""This should be implemented by the subclass. The implemented method should raise a SystemError if
              the request does not exists!""")
        raise RuntimeError







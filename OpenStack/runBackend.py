"""
   Copyright (C) 2025  Argyros Argyridis arargyridis at gmail dot com
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

import json, openstack, os, paramiko, subprocess, sys, time

class OpenStackSSH(object):
    def __init__(self, name, sshOptions):
        self._name = name
        self._client = paramiko.SSHClient()
        self._client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self._options = sshOptions

    def connect(self):
        connected = False

        while not connected:
            try:
                self._client.connect(hostname=self._options["host"], port=self._options["port"], username=self._options["user"], pkey=paramiko.RSAKey.from_private_key_file(self._options["key"], self._options["passphrase"]))
                connected = True
                print("Connection established to: ", self._name)
            except:
                print("Waiting for SSH connection ({0})...".format(self._name))
                time.sleep(5)

    def execCommands(self, commands):
        for cmd in commands:
            channel = self._client.invoke_shell()
            channel.send(cmd["exec"])

            log = open(cmd["logFile"], "w")

            while not channel.recv_ready():
                channel.recv(1024)
                time.sleep(0.1)

            # clear out any initial text

            stop = False
            while not stop:
                output = channel.recv(1024).decode("utf-8")
                log.write(output)
                log.flush()
                print(output, end='')
                #stop = channel.exit_status_ready()
                stop = output.strip().endswith("$") or output.strip().endswith("#")
                time.sleep(0.1)


    def __del__(self):
        self._client.close()


def runInstance(instance, ssh):
    conn = openstack.connect(cloud=None)
    server = conn.compute.get_server(instance["id"])

    #check if server should be unshelved
    if server.status == "SHELVED_OFFLOADED":
        conn.compute.unshelve_server(server)

    #for some reason the server is already computing...
    if server.status == "ACTIVE":
        return 1

    sshCn = OpenStackSSH(instance["name"], ssh)

    unShelved = False
    while not unShelved:
        server = conn.compute.get_server(instance["id"])
        unShelved = server.status == "ACTIVE"
        print("{0} status: {1}".format(server.name, server.status))
        if not unShelved:
            time.sleep(10)

    sshCn.connect()
    sshCn.execCommands(instance["commands"])
    sshCn = None

    conn.compute.shelve_server(server)
    while unShelved:
        server = conn.compute.get_server(instance["id"])
        unShelved = server.status != "SHELVED_OFFLOADED"
        print("{0} status: {1}".format(server.name, server.status))
        if unShelved:
            time.sleep(10)


def main():
    if len(sys.argv) < 2:
        print("Usage: python runBackend.py config.json")
        return 1

    configOptions=json.load(open(sys.argv[1]))

    for key in configOptions["credentials"]:
        os.environ[key] = configOptions["credentials"][key]

    #running only for first instance, if needed this can be done in parallel for multiple ones!
    runInstance(configOptions["options"]["instances"][0], configOptions["options"]["ssh"][configOptions["options"]["instances"][0]["ssh"]])



    return 0



if __name__ == "__main__":
    main()

# -*- coding: utf-8 -*-
import docker
import subprocess
client = docker.from_env()
events = client.events(decode=True)

def get_container_host_port(container_id):
    container = client.containers.get(container_id)
    attrs = container.attrs
    ports = attrs['NetworkSettings']['Ports']
    if ports:
        for port in ports:
            return ports[port][0]['HostPort']
    return None

def on_container_start(event):
    print(event['Type'])
    if event['Type'] != 'container':
        return None

    if event['Action'] != 'start' and event['Action'] != 'stop':
        return None

    container_ports = {}
    for container in client.containers.list():
        port = get_container_host_port(container.id)
        print(port)
        if port != None:
            container_ports[container.name] = port

    count = 0
    # set all ports to nginx mappings
    nginx = '/etc/nginx/includes/docker_ports'
    with open(nginx, 'w') as f:
        #port default
        f.write(f"default 38000;\n")
        #port containers
        for container, port in container_ports.items():
            f.write(f"{container} {port};\n")
            count += 1

    print(f"write ports containers: {count}")
    subprocess.call(['sudo', 'nginx', '-s', 'reload'])
    print(f"nginx reload")
try:
    for event in events:
        on_container_start(event)
except KeyboardInterrupt:
    events.close()

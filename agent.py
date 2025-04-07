import psutil
import requests
import cpuinfo
import asyncio
import json
import time
from uptime import uptime
import socket

with open('config.json',"r") as file:
    config = json.load(file)
ID = config['id']
API_URL = config["API_URL"]
API_KEY = config["API_KEY"]

def get_usage():
    up = uptime()
    time = float(up)
    day = time // (24 * 3600)
    time = time % (24 * 3600)
    hour = time // 3600
    time %= 3600
    minutes = time // 60
    time %= 60
    seconds = time
    uptime_stamp = ("%dd %dh %dm %ds" % (day, hour, minutes, seconds))
    res = requests.get("ipinfo.io").json()
    ip = res['ip']
    return {
        "id": ID,
        "cpu": psutil.cpu_percent(),
        "ram": f"{round(psutil.virtual_memory().used/1000000000, 2)}GB / {round(psutil.virtual_memory().total/1000000000, 2)}GB",
        "swap": f"{round(psutil.swap_memory().used/1000000000, 2)}GB / {round(psutil.swap_memory().total/1000000000, 2)}GB",
        "disk": f"{round(psutil.disk_usage('/').used/1000000000, 2)}GB / {round(psutil.disk_usage('/').total/1000000000, 2)}GB",
        "uptime": uptime_stamp,
        "cpuinfo": cpuinfo.get_cpu_info()["brand_raw"],
        "threads": cpuinfo.get_cpu_info()["count"],
        "ip": ip
    }

while True:
    try:
        headers = {"x-api-key": API_KEY}
        requests.post(API_URL, json=get_usage(), headers=headers)
    except Exception as e:
        print(f"Error: {e}")
    time.sleep(15)

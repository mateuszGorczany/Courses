# %%
import serial
import numpy as np
import time
# %%

class DataCollector:

    def __init__(
        self,
        port: str = "/dev/ttyACM0",
        baudrate: int = 9600,
        timeout: int = 1
    ) -> None:
        self.serial_port = serial.Serial(
            port=port,
            baudrate=baudrate,
            timeout=timeout,
        )

    def radar_data(self):
        while(1):
            if self.serial_port.in_waiting == 0:
                continue
            data = self.serial_port.readline().decode("ASCII", "ignore")
            try:
                angle, distance= [float(x) for x in data.split(",")]
            except Exception:
                angle, distance = 0, 0
            yield angle, distance

if __name__ == "__main__":
    pass

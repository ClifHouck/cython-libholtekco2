import holtekco2
import time

device = holtekco2.CO2Device()

for i in range(0, 100):
    try:
        print device.read_data()
    except Exception as e:
        pass
        #print e, e.data

    time.sleep(0.1)

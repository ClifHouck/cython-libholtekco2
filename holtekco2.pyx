cimport holtekco2


cdef class CO2Device:
    cdef holtekco2.co2_device* _c_co2_device

    def __cinit__(self):
        print("Device init!")
        self._c_co2_device = holtekco2.co2_open_first_device()
        print("{0:x}".format(<unsigned int>self._c_co2_device))

    def __dealloc__(self):
        print("Device dealloc!")
        holtekco2.co2_close(self._c_co2_device)

    def send_init_packet(self):
        holtekco2.co2_send_init_packet(self._c_co2_device)

    def read_data(self):
        cdef co2_device_data data = \
            holtekco2.co2_read_data(self._c_co2_device)

        if data.tag == CO2:
            return { 'type': 'co2',
                     'data': data.value }
        elif data.tag == TEMP:
            return { 'type': 'fahrenheit',
                     'data': holtekco2.co2_get_fahrenheit_temp(data.value) }
        else:
            e = Exception("Unrecognized data type!")
            e.data = data
            raise e

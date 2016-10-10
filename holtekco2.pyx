cimport holtekco2


class CO2Exception(Exception):
    """Base class for all Exceptions emitted by cython-holtekco2."""
    pass


class NoDeviceFoundException(CO2Exception):
    """Exception raised when no holtek CO2 device is found."""
    pass


class ProblemReadingDataException(CO2Exception):
    """Raised when something goes wrong when reading data from a CO2 device."""
    pass


cdef class CO2Device:
    cdef holtekco2.co2_device* _c_co2_device

    def __cinit__(self):
        """Initializes CO2 Device to first matching device.

        If you need to address more than one device, then please extend this
        wrapper and make a PR :)

        :raises: NoDeviceFoundException if no device is found.
        """
        self._c_co2_device = holtekco2.co2_open_first_device()
        if self._c_co2_device == NULL:
            raise NoDeviceFoundException("Failed to open/init a Holtek CO2 "
                                         "device!")

    def __dealloc__(self):
        """Deallocates/destroys this device class by close the device handle.
        """
        holtekco2.co2_close(self._c_co2_device)

    def _send_init_packet(self):
        holtekco2.co2_send_init_packet(self._c_co2_device)

    def read_raw_data(self):
        """Reads the next piece of data from the device regardless of type.

        :returns: dict - The data returned by the device. The dict has the
            following keys: 'tag', 'value', 'checksum', and 'valid'
        """
        cdef co2_device_data data = \
            holtekco2.co2_read_data(self._c_co2_device)

        return { 
            k: getattr(data, k) for k in ('tag', 'value', 'checksum', 'valid') 
        }
       
    def read_data(self):
        """Reads the next available recognizable piece of data from the device.

        :returns: dict - Data returned by the device. Dict consists of the 
            following keys: 'type', 'value', and 'units'. 

            'type' is one of 'co2', 'temperature', or 'humidity'.
            'value' is the actual data value
            'unit' the unit of measurement applicable to 'value'

        :raises: ProblemReadingDataException
        """
        # NOTE(ClifHouck): From my limited experiments it only takes 3-4 reads
        # to get to a recognizable data read, but trying a few more times here
        # for convenience's sake.
        for i in range(0, 10):
            cdef co2_device_data data = \
                holtekco2.co2_read_data(self._c_co2_device)

            if data.tag == CO2:
                return {'type': 'co2',
                        'value': data.value,
                        'unit': 'ppm'}
            elif data.tag == TEMP:
                return {'type': 'temperature',
                        'value': holtekco2.co2_get_fahrenheit_temp(data.value),
                        'unit': 'degrees fahrenheit'}
            elif data.tag == HUMIDITY:
                return {'type': 'humidity',
                        'value': holtekco2.co2_get_relative_humidity(data.value),
                        'unit': 'percentage'}

        raise ProblemReadingDataException(
            "Repeated attempts to read from device only returned "
            "unrecognizable data!"
        )

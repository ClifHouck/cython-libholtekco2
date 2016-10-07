cdef extern from "holtekco2.h":
    ctypedef struct co2_device:
        pass

    ctypedef unsigned short uint16_t
    ctypedef unsigned char uint8_t

    cdef enum co2_data_types:
        CO2 = 0x50
        TEMP = 0x42
        HUMIDITY = 0x44

    cdef struct tag_co2_device_data:
        uint8_t tag
        uint16_t value
        uint8_t checksum
        bint valid
    
    ctypedef tag_co2_device_data co2_device_data

    ctypedef struct hid_device_info:
        pass

    hid_device_info * co2_enumerate()
    void co2_free_enumeration(hid_device_info *devs)

    co2_device * co2_raw_open_device_path(const char *path)
    co2_device * co2_open_device_path(const char *path)
    co2_device * co2_raw_open_first_device()
    co2_device * co2_open_first_device()

    void co2_close(co2_device *device)

    void co2_gen_usb_enc_key(uint8_t key[8])

    int co2_send_init_packet(co2_device *device)

    void co2_decrypt_buf(const uint8_t key[8], uint8_t buffer[8])

    co2_device_data co2_read_data(co2_device *device)
    int co2_raw_read_decode_data(co2_device *device, uint8_t buffer[8])
    int co2_raw_read_data(co2_device *device, uint8_t buffer[8])

    double co2_get_celsius_temp(uint16_t value)
    double co2_get_fahrenheit_temp(uint16_t value)
    double co2_get_relative_humidity(uint16_t value)

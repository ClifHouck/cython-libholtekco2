rm ./holtekco2.so
CFLAGS="-I/home/clif/git_repos/libholtekco2/include/ -I/usr/include/hidapi/ -v" \
LDFLAGS="-L/home/clif/git_repos/libholtekco2/src/ -lholtekco2 -lhidapi-libusb" \
    python setup.py build_ext -i

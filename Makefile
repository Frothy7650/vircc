vircc.so:
	v -shared -prod -parallel-cc -cc clang . -o lib/so/libvircc.so

install:
	# Install the .so library
	sudo cp -r lib/so/libvircc.so /usr/lib/
	# Install the header files
	sudo cp -r lib/header/vircc.h /usr/include/

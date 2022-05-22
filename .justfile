@build:
    make -j

@clean:
    make clean
    
run: build
    cd ../f68-emulator/emulator; ./f68 {{justfile_directory()}}/hello.pgz go
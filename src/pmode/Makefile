ASM=nasm

SRC_DIR=.
BUILD_DIR=../../pmode_build

image: $(BUILD_DIR)/pmode.img 

$(BUILD_DIR)/pmode.img: $(BUILD_DIR)/boot.bin
	cp $(BUILD_DIR)/boot.bin $(BUILD_DIR)/pmode.img 
	truncate -s 1440k $(BUILD_DIR)/pmode.img 

$(BUILD_DIR)/boot.bin: $(SRC_DIR)/main.asm always
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/boot.bin

always:
	mkdir -p $(BUILD_DIR)

run: image
	qemu-system-i386 -fda $(BUILD_DIR)/pmode.img

debug: image
	bochs -f $(SRC_DIR)/bochs-config

.PHONY: image run debug always

# Source files
ASM_SRCS = \
	mandelbrot.s

C_SRCS = \
	main.c

# Paths
VPATH = src
DEPS_DEBUG_PATH = .deps
DEPS_RELEASE_PATH = .deps-release
BUILD_DEBUG_PATH = build
BUILD_RELEASE_PATH = build-release

# Foenix support library
FOENIX = module/foenix-m68k
MODEL = --code-model=large --data-model=small
LIB_MODEL = lc-sd

FOENIX_LIB = $(FOENIX)/foenix-$(LIB_MODEL).a
A2560U_RULES = $(FOENIX)/linker-files/a2560u-simplified.scm
A2560K_RULES = $(FOENIX)/linker-files/a2560k-simplified.scm

# Object files
OBJS_RELEASE = $(ASM_SRCS:%.s=$(BUILD_RELEASE_PATH)/%.o) $(C_SRCS:%.c=$(BUILD_RELEASE_PATH)/%.o)
OBJS_DEBUG = $(ASM_SRCS:%.s=$(BUILD_DEBUG_PATH)/%.o) $(C_SRCS:%.c=$(BUILD_DEBUG_PATH)/%.o)

# Build rules
C_FLAGS = --pedantic-errors -Wall $(MODEL)

$(BUILD_RELEASE_PATH)/%.o: %.s $(DEPS_RELEASE_PATH)/%.d | $(DEPS_RELEASE_PATH) $(BUILD_RELEASE_PATH)
	motor68k -fe -d$(DEPS_RELEASE_PATH)/$*.d -o$@ $<

$(BUILD_RELEASE_PATH)/%.o: %.c $(DEPS_RELEASE_PATH)/%.d | $(DEPS_RELEASE_PATH) $(BUILD_RELEASE_PATH)
	@cc68k --core=68000 $(C_FLAGS) -O2 --debug --dependencies -MQ$@ >$(DEPS_RELEASE_PATH)/$*.d $<
	cc68k --core=68000 $(C_FLAGS) -O2 --debug --list-file=$(@:%.o=%.lst) -o $@ $<

$(BUILD_DEBUG_PATH)/%.o: %.s $(DEPS_DEBUG_PATH)/%.d | $(DEPS_DEBUG_PATH) $(BUILD_DEBUG_PATH)
	motor68k -fe -d$(DEPS_DEBUG_PATH)/$*.d -o$@ $<

$(BUILD_DEBUG_PATH)/%.o: %.c $(DEPS_DEBUG_PATH)/%.d | $(DEPS_DEBUG_PATH) $(BUILD_DEBUG_PATH)
	@cc68k --core=68000 $(C_FLAGS) --debug --dependencies -MQ$@ >$(DEPS_DEBUG_PATH)/$*-debug.d $<
	cc68k --core=68000 $(C_FLAGS) --debug --list-file=$(@:%.o=%.lst) -o $@ $<

hello.pgz:  $(OBJS_RELEASE) $(FOENIX_LIB)
	ln68k -o $@ $^ $(A2560U_RULES) clib-68000-$(LIB_MODEL)-Foenix.a --output-format=pgz --list-file=$(BUILD_RELEASE_PATH)/$@.lst --cross-reference --rtattr printf=reduced --rtattr cstartup=Foenix_user

hello.elf: $(OBJS_DEBUG)
	ln68k --debug -o $@ $^ $(A2560U_RULES) clib-68000-$(LIB_MODEL).a --list-file=$(BUILD_DEBUG_PATH)/$@.lst --cross-reference --rtattr printf=reduced --semi-hosted --target=Foenix --stack-size=2000 --sstack-size=800

hello.hex:  $(OBJS_DEBUG) $(FOENIX_LIB)
	ln68k -o $@ $^ $(A2560K_RULES) clib-68000-$(LIB_MODEL)-Foenix.a --output-format=intel-hex --list-file=$(BUILD_DEBUG_PATH)/$@.lst --cross-reference --rtattr printf=reduced --rtattr cstartup=Foenix_morfe --stack-size=2000

$(FOENIX_LIB):
	(cd $(FOENIX) ; $(MAKE) all)

# Clean utility
clean:
	-rm -rf $(BUILD_RELEASE_PATH) $(BUILD_DEBUG_PATH) $(FOENIX_LIB) $(DEPS_RELEASE_PATH) $(DEPS_DEBUG_PATH) 
	-rm hello.elf hello.pgz hello.hex
	-(cd $(FOENIX) ; $(MAKE) clean)


# Make directory utility
$(DEPS_RELEASE_PATH) $(DEPS_DEBUG_PATH) $(BUILD_RELEASE_PATH) $(BUILD_DEBUG_PATH): ; @mkdir -p $@

# Dependency files
DEP_RELEASE_FILES := $(C_SRCS:%.c=$(DEPS_RELEASE_PATH)/%.d) $(ASM_SRCS:%.s=$(DEPS_RELEASE_PATH)/%.d)
DEP_DEBUG_FILES := $(C_SRCS:%.c=$(DEPS_DEBUG_PATH)/%.d) $(ASM_SRCS:%.s=$(DEPS_DEBUG_PATH)/%.d)

$(DEP_RELEASE_FILES):

$(DEP_DEBUG_FILES):

include $(wildcard $(DEP_RELEASE_FILES) $(DEP_DEBUG_FILES))
# Usage
# $ make all

ZIP=zip
RM=rm
VERSION=1.0.2
MOD_BASE_NAME=Camera-chan
MOD_VERSIONED_NAME=${MOD_BASE_NAME}_${VERSION}
OUTPUT=${MOD_VERSIONED_NAME}.zip
TOZIP=info.json changelog.txt control.lua data.lua style.lua LICENSE

.PHONY: all
all: setup

.PHONY: setup
setup: ${OUTPUT}

${OUTPUT}:
	mkdir ${MOD_VERSIONED_NAME}
	cp ${TOZIP} ${MOD_VERSIONED_NAME}
	${ZIP} -r ${OUTPUT} ${MOD_VERSIONED_NAME}
	rm -rf ${MOD_VERSIONED_NAME}

.PHONY: clean
clean:
	${RM} -f ${OUTPUT}
	${RM} -rf ${MOD_VERSIONED_NAME}

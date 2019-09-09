MOCKS_VERSION=DSP2043_1.2.0
EMU_SOURCE=https://github.com/DMTF/Redfish-Interface-Emulator/archive/1.1.2.tar.gz
MOCKS_SOURCE=https://www.dmtf.org/sites/default/files/$(MOCKS_VERSION).zip
IMAGE=bmctoolbox/redfish-interface-emulator

DIR := $(shell mktemp -ud)

# redfish mocks
BLADED = $(DIR)/$(MOCKS_VERSION)/public-bladed
BLADED_PARTITIONS = $(DIR)/$(MOCKS_VERSION)/public-bladed-partitions
LOCALSTORAGE = $(DIR)/$(MOCKS_VERSION)/public-localstorage
RACKMOUNT = $(DIR)/$(MOCKS_VERSION)/public-rackmount1

IP = 172.19.0.99

network:
	(docker network list | grep -q redfish ) ||  docker network create --subnet=172.19.0.0/16 redfish

# static mock
#docker run -it --mount type=bind,source="$(pwd)"/hpegen10/redfish/v1,target=/usr/src/app/api_emulator/redfish/static --rm redfish-interface-emulator
run-bladed:
	echo $(BLADED)
	docker run --net redfish --ip $(IP) --mount source=redfish_profile,target=$(BLADED) --rm $(IMAGE)
run-localstorage:
	docker run --net redfish --ip $(IP) --mount source=redfish_profile,target=$(LOCAL_STORAGE) --rm $(IMAGE)
run-rackmount:
	docker run --net redfish --ip $(IP) --mount source=redfish_profile,target=$(RACKMOUNT) --rm $(IMAGE)
run-bladed-partitions:
	docker run --net redfish --ip $(IP) --mount source=redfish_profile,target=$(RACKMOUNT) --rm $(IMAGE)

stop:
	docker network remove redfish
	docker stop 

scratch-build:
	mkdir -p $(DIR)
	wget $(EMU_SOURCE) -O - | tar -xvzf - -C $(DIR)
	cp Dockerfile $(DIR)/Redfish-Interface-Emulator-1.1.2/
	wget $(MOCKS_SOURCE) -O $(DIR)/$(MOCKS_VERSION).zip
	unzip $(DIR)/$(MOCKS_VERSION).zip -d $(DIR)
	docker build -f $(DIR)/Redfish-Interface-Emulator-1.1.2/Dockerfile -t bmctoolbox/redfish-interface-emulator $(DIR)/Redfish-Interface-Emulator-1.1.2/

build:
	docker build -f $(DIR)/Redfish-Interface-Emulator-1.1.2/Dockerfile -t bmctoolbox/redfish-interface-emulator $(DIR)/Redfish-Interface-Emulator-1.1.2/

push:
	docker login && docker push bmctoolbox/redfish-interface-emulator:latest

all: scratch-build network run-bladed

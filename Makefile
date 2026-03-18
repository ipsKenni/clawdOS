ISO_NAME := clawdos
VERSION := $(shell git describe --tags --always 2>/dev/null || echo "dev")
OUTPUT_DIR := output
DOCKER_IMAGE := clawdos-builder

.PHONY: iso docker-build-env test lint clean qemu qemu-gui

iso: docker-build-env
	docker run --rm \
		-v "$(CURDIR)":/build \
		-v "$(CURDIR)/$(OUTPUT_DIR)":/build/$(OUTPUT_DIR) \
		--privileged \
		$(DOCKER_IMAGE) \
		/build/build/build.sh

docker-build-env:
	docker build -t $(DOCKER_IMAGE) build/

test:
	@echo "Running tests..."
	@for t in tests/*.sh; do \
		if [ -f "$$t" ]; then \
			echo "  Running $$t"; \
			bash "$$t" || exit 1; \
		fi; \
	done
	@echo "All tests passed."

lint:
	@echo "Running shellcheck..."
	@shellcheck $$(find . -name '*.sh' -not -path './output/*' -not -path './.cache/*' -not -path './tmp/*')
	@if [ -d rootfs/usr/local/bin ]; then \
		for f in rootfs/usr/local/bin/*; do \
			if [ -f "$$f" ] && head -1 "$$f" | grep -q '^#!.*sh'; then \
				shellcheck "$$f"; \
			fi; \
		done; \
	fi
	@echo "Lint passed."

clean:
	rm -rf $(OUTPUT_DIR)

qemu:
	qemu-system-x86_64 \
		-m 1024 \
		-cdrom $(OUTPUT_DIR)/$(ISO_NAME)-$(VERSION).iso \
		-boot d \
		-serial stdio \
		-display none

qemu-gui:
	qemu-system-x86_64 \
		-m 1024 \
		-cdrom $(OUTPUT_DIR)/$(ISO_NAME)-$(VERSION).iso \
		-boot d \
		-serial stdio

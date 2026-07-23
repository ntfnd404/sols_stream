.DEFAULT_GOAL := help

.PHONY: help install-hooks fetch-idl check-idl require-idl-rpc generate-solana-sdk check-solana-sdk \
        verify-staged check-dcm check-app-config validate-local-config validate-dev-config validate-prod-config \
        node-up node-down node-logs node-status node-reset node-shell node-build-arm64 \
        run-local-mobile run-local-android run-local-ios run-local-macos run-local-linux \
        run-local-windows run-local-web run-local-web-debug \
        run-local-chrome run-local-chrome-debug \
        run-dev-mobile run-dev-android run-dev-ios run-dev-macos run-dev-linux \
        run-dev-windows run-dev-web run-dev-chrome \
        run-prod-mobile run-prod-android run-prod-ios run-prod-macos run-prod-linux \
        run-prod-windows run-prod-web

LOCAL_WEB_ENV_FILE ?= config/tooling/local_web.env
IDL_ENV_FILE ?= config/tooling/idl.env
-include $(LOCAL_WEB_ENV_FILE)
-include $(IDL_ENV_FILE)

IDL_OUT ?= packages/signaling_solana/idl/sols_stream.json
IDL_INPUT := $(abspath $(IDL_OUT))
IDL_INPUT_ROOT := $(dir $(IDL_INPUT))
SOLANA_SDK_OUTPUT ?= packages/signaling_solana/lib/src/generated
SOLANA_SDK_OUTPUT_ABS := $(abspath $(SOLANA_SDK_OUTPUT))

# ============================================
# Help
# ============================================
help:
	@echo "Project: sols.stream"
	@echo ""
	@echo "Setup:"
	@echo "  make install-hooks       Install git hooks"
	@echo "  make fetch-idl           Refresh on-chain IDL"
	@echo "  make check-idl           Verify versioned IDL"
	@echo "  make generate-solana-sdk Regenerate the internal Solana wire SDK"
	@echo "  make check-solana-sdk    Verify generated Solana SDK drift"
	@echo "  make verify-staged       Verify the exact HEAD + staged snapshot"
	@echo "  make check-dcm           Run advisory DCM checks with their real exit code"
	@echo "  make check-app-config    Validate tracked Flutter dart-define files"
	@echo ""
	@echo "Local Solana node:"
	@echo "  make node-up             Start local validator"
	@echo "  make node-down           Stop local validator"
	@echo "  make node-logs           Tail validator logs"
	@echo "  make node-status         Show validator status"
	@echo "  make node-reset          Wipe state and restart"
	@echo ""
	@echo "Run app:"
	@echo "  make run-local-macos     Local node, macOS"
	@echo "  make run-local-web       Local node, web-server :8080"
	@echo "  make run-local-chrome    Local node, managed Chrome"
	@echo "  make run-dev-macos       Devnet, macOS"
	@echo "  make run-dev-web         Devnet, web-server :8080"
	@echo "  make run-dev-chrome      Devnet, managed Chrome"

# ============================================
# Setup
# ============================================
install-hooks:
	@cp .claude/hooks/git-pre-commit.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Git pre-commit hook installed."

require-idl-rpc:
	@if [ -z "$(strip $(IDL_RPC_URL))" ]; then \
		echo "IDL_RPC_URL is required. Set it directly or in $(IDL_ENV_FILE)." >&2; \
		exit 2; \
	fi

fetch-idl: require-idl-rpc
	@dart run packages/signaling_solana/tool/fetch_idl.dart \
		--rpc-url "$(IDL_RPC_URL)" \
		--out "$(IDL_OUT)"

check-idl: require-idl-rpc
	@dart run packages/signaling_solana/tool/fetch_idl.dart \
		--rpc-url "$(IDL_RPC_URL)" \
		--out "$(IDL_OUT)" \
		--check

generate-solana-sdk:
	@echo "Generating signaling_solana SDK from $(IDL_OUT)..."
	@cd tool/solana_codegen && \
		dart run solana_idl_codegen generate "$(IDL_INPUT)" \
			--input-root "$(IDL_INPUT_ROOT)" \
			--output "$(SOLANA_SDK_OUTPUT_ABS)" \
			--layout modular
	@echo "Solana SDK generation completed."

check-solana-sdk:
	@echo "Checking signaling_solana SDK for generated drift..."
	@cd tool/solana_codegen && \
		dart run solana_idl_codegen generate "$(IDL_INPUT)" \
			--input-root "$(IDL_INPUT_ROOT)" \
			--output "$(SOLANA_SDK_OUTPUT_ABS)" \
			--layout modular \
			--check
	@echo "Solana SDK is up to date."

verify-staged:
	@tool/quality/verify_staged.sh

check-dcm:
	@dcm analyze lib/ packages/ test/ --fatal-style --fatal-warnings

check-app-config:
	@dart run tool/quality/validate_dart_defines.dart config/local.env
	@dart run tool/quality/validate_dart_defines.dart config/dev.env
	@dart run tool/quality/validate_dart_defines.dart config/prod.example.env

# ============================================
# Local Solana node
# ============================================
AGAVE_VERSION ?= v2.1.21
AGAVE_COMMIT ?= 8a085eebcb901b6846d1f82f4636667742146545

node-up:
	@docker compose -f docker/docker-compose.yml up -d --wait --wait-timeout 180

node-down:
	@docker compose -f docker/docker-compose.yml down

node-logs:
	@docker compose -f docker/docker-compose.yml logs -f solana-node

node-status:
	@docker compose -f docker/docker-compose.yml ps solana-node

node-reset:
	@docker compose -f docker/docker-compose.yml down -v
	@docker compose -f docker/docker-compose.yml up -d --wait --wait-timeout 180

node-shell:
	@docker compose -f docker/docker-compose.yml exec solana-node sh

node-build-arm64:
	@docker build --platform linux/arm64 \
	    --build-arg AGAVE_VERSION="$(AGAVE_VERSION)" \
	    --build-arg AGAVE_COMMIT="$(AGAVE_COMMIT)" \
	    -f docker/Dockerfile.solana-arm64 \
	    -t solana-local:arm64 \
	    docker/

# ============================================
# Run app
# ============================================
LOCAL_CONFIG_FILE ?= config/local.env
DEV_CONFIG_FILE ?= config/dev.env
PROD_CONFIG_FILE ?= config/prod.env

LOCAL_DEFINES := --dart-define-from-file=$(LOCAL_CONFIG_FILE)
DEV_DEFINES := --dart-define-from-file=$(DEV_CONFIG_FILE)
PROD_DEFINES := --dart-define-from-file=$(PROD_CONFIG_FILE)

DEVICE ?=
DEVICE_OPTION := $(if $(strip $(DEVICE)),-d "$(DEVICE)",)

validate-local-config:
	@dart run tool/quality/validate_dart_defines.dart "$(LOCAL_CONFIG_FILE)"

validate-dev-config:
	@dart run tool/quality/validate_dart_defines.dart "$(DEV_CONFIG_FILE)"

validate-prod-config:
	@dart run tool/quality/validate_dart_defines.dart "$(PROD_CONFIG_FILE)"

run-local-mobile: validate-local-config
	flutter run $(DEVICE_OPTION) $(LOCAL_DEFINES)

run-local-android: run-local-mobile

run-local-ios: run-local-mobile

run-local-macos: validate-local-config
	flutter run -d macos $(LOCAL_DEFINES)

run-local-linux: validate-local-config
	flutter run -d linux $(LOCAL_DEFINES)

run-local-windows: validate-local-config
	flutter run -d windows $(LOCAL_DEFINES)

run-local-web: validate-local-config
	flutter run -d web-server --release \
		--web-hostname "$(LOCAL_WEB_BIND_HOST)" \
		--web-port "$(LOCAL_WEB_BIND_PORT)" \
		$(LOCAL_DEFINES)

run-local-web-debug: validate-local-config
	flutter run -d web-server \
		--web-hostname "$(LOCAL_WEB_BIND_HOST)" \
		--web-port "$(LOCAL_WEB_BIND_PORT)" \
		$(LOCAL_DEFINES)

run-local-chrome: validate-local-config
	flutter run -d chrome \
		--web-hostname "$(LOCAL_WEB_BIND_HOST)" \
		--web-port "$(LOCAL_WEB_BIND_PORT)" \
		$(LOCAL_DEFINES)

run-local-chrome-debug: run-local-chrome

run-dev-mobile: validate-dev-config
	flutter run $(DEVICE_OPTION) $(DEV_DEFINES)

run-dev-android: run-dev-mobile

run-dev-ios: run-dev-mobile

run-dev-macos: validate-dev-config
	flutter run -d macos $(DEV_DEFINES)

run-dev-linux: validate-dev-config
	flutter run -d linux $(DEV_DEFINES)

run-dev-windows: validate-dev-config
	flutter run -d windows $(DEV_DEFINES)

run-dev-web: validate-dev-config
	flutter run -d web-server --release \
		--web-hostname "$(LOCAL_WEB_BIND_HOST)" \
		--web-port "$(LOCAL_WEB_BIND_PORT)" \
		$(DEV_DEFINES)

run-dev-chrome: validate-dev-config
	flutter run -d chrome \
		--web-hostname "$(LOCAL_WEB_BIND_HOST)" \
		--web-port "$(LOCAL_WEB_BIND_PORT)" \
		$(DEV_DEFINES)

run-prod-mobile: validate-prod-config
	flutter run $(DEVICE_OPTION) --release $(PROD_DEFINES)

run-prod-android: run-prod-mobile

run-prod-ios: run-prod-mobile

run-prod-macos: validate-prod-config
	flutter run -d macos --release $(PROD_DEFINES)

run-prod-linux: validate-prod-config
	flutter run -d linux --release $(PROD_DEFINES)

run-prod-windows: validate-prod-config
	flutter run -d windows --release $(PROD_DEFINES)

run-prod-web: validate-prod-config
	flutter run -d chrome --release $(PROD_DEFINES)

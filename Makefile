.PHONY: help build build-protocol build-engine build-fe build-remote dev-up dev-down test test-protocol test-engine test-fe test-liveapi mock-api deploy clean logs

REGISTRY := ghcr.io/jbflow
PROTOCOL_IMAGE := $(REGISTRY)/musical-intent-protocol
ENGINE_IMAGE := $(REGISTRY)/mantra-engine
FE_IMAGE := $(REGISTRY)/mantra-fe
REMOTE_IMAGE := $(REGISTRY)/mantra-remote-script

help:
	@echo "Mantra Docker Orchestration"
	@echo ""
	@echo "WORKFLOWS:"
	@echo "  Local Dev (all repos cloned as siblings):"
	@echo "    make dev-up              Start services with local source"
	@echo "    make test                Run tests in containers"
	@echo "    make dev-down            Stop services"
	@echo ""
	@echo "  Fresh Machine (GitHub sources):"
	@echo "    make build-fresh         Build all services from GitHub"
	@echo "    make test-fresh          Run tests from GitHub sources"
	@echo "    make dev-up-fresh        Start services from GitHub"
	@echo ""
	@echo "  Production (pre-built registry images):"
	@echo "    make build               Build all locally"
	@echo "    make build-protocol      Build musical-intent-protocol"
	@echo "    make build-engine        Build mantra-engine"
	@echo "    make build-fe            Build mantra-fe"
	@echo "    make build-remote        Build mantra-remote-script"
	@echo "    make deploy              Push all images to registry"
	@echo ""
	@echo "  Utilities:"
	@echo "    make mock-api            Run mock API server"
	@echo "    make logs                Show logs from services"
	@echo "    make clean               Clean up containers and networks"

build: build-protocol build-engine build-fe build-remote
	@echo "✓ All images built successfully"

build-protocol:
	@echo "Building musical-intent-protocol..."
	docker build -t $(PROTOCOL_IMAGE):latest ../musical-intent-protocol

build-engine:
	@echo "Building mantra-engine..."
	docker build -t $(ENGINE_IMAGE):latest ../mantra-engine

build-fe:
	@echo "Building mantra-fe..."
	docker build -t $(FE_IMAGE):latest ../mantra-fe

build-remote:
	@echo "Building mantra-remote-script..."
	docker build -t $(REMOTE_IMAGE):latest ../mantra-remote-script

dev-up:
	@echo "Starting Mantra services in development mode..."
	docker compose -f docker-compose.local.yml up -d
	@echo "✓ Services started"
	@echo ""
	@echo "Service endpoints:"
	@echo "  Frontend:        http://localhost:3002"
	@echo "  Engine:          http://localhost:3001"
	@echo "  Protocol:        http://localhost:3000"
	@echo "  Remote Script:   http://localhost:9001"
	@echo "  LiveAPI-mock:    http://localhost:9999"

dev-down:
	@echo "Stopping Mantra services..."
	docker compose -f docker-compose.local.yml down
	@echo "✓ Services stopped"

test: test-protocol test-engine test-fe test-liveapi
	@echo "✓ All tests passed"

test-protocol:
	@echo "Running protocol tests..."
	cd ../musical-intent-protocol && npm test

test-engine:
	@echo "Running engine tests..."
	cd ../mantra-engine && npm test

test-fe:
	@echo "Running frontend tests..."
	cd ../mantra-fe && npm test

test-liveapi:
	@echo "Running LiveAPI-mock tests in Docker..."
	docker compose -f docker-compose.local.yml run --rm liveapi-mock pytest tests/ -v

test-fresh:
	@echo "Testing all services from GitHub sources..."
	docker compose -f docker-compose.build.yml up --abort-on-container-exit
	@echo "✓ All tests passed"

mock-api:
	@echo "Starting mock API server..."
	docker run --rm -it -p 9001:9001 $(REMOTE_IMAGE):latest

build-fresh:
	@echo "Building all services from GitHub sources..."
	docker compose -f docker-compose.build.yml build

dev-up-fresh:
	@echo "Starting services from GitHub sources..."
	docker compose -f docker-compose.build.yml up -d
	@echo "✓ Services started"
	@echo ""
	@echo "Service endpoints:"
	@echo "  Frontend:        http://localhost:3002"
	@echo "  Engine:          http://localhost:3001"
	@echo "  Protocol:        http://localhost:3000"
	@echo "  Remote Script:   http://localhost:9001"
	@echo ""
	@echo "Note: Images built from GitHub sources on this machine"

deploy:
	@echo "Deploying to registry..."
	docker push $(PROTOCOL_IMAGE):latest
	docker push $(ENGINE_IMAGE):latest
	docker push $(FE_IMAGE):latest
	docker push $(REMOTE_IMAGE):latest
	@echo "✓ All images pushed to registry"

logs:
	docker compose -f docker-compose.local.yml logs -f

clean:
	@echo "Cleaning up Docker resources..."
	docker compose -f docker-compose.local.yml down -v
	docker system prune -f
	@echo "✓ Cleanup complete"

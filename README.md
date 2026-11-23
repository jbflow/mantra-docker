# Mantra Docker Orchestration

Coordinated Docker deployment for the Mantra musical intent platform.

## Two Workflows

### 1. Local Development (All repos cloned as siblings)

Best for iterative development with live code changes.

```bash
# Directory structure needed:
# mantra/
#   ├── musical-intent-protocol/
#   ├── mantra-engine/
#   ├── mantra-fe/
#   ├── mantra-remote-script/
#   └── mantra-docker/

cd mantra-docker

# Install dependencies and start services
make dev-up

# View logs
make logs

# Run tests in containers
make test

# Stop services
make dev-down
```

**Benefits:**
- Live code reloading (volume mounts)
- Fast iteration cycle
- Exact development environment

**Uses:** `docker-compose.local.yml` with volume mounts to ../sibling directories

---

### 2. Fresh Machine / Any Machine (Build from GitHub)

Best for CI/CD, testing on fresh machines, or when you don't have all repos cloned.

```bash
# Only need mantra-docker cloned
cd mantra-docker

# Build all services from GitHub sources
make build-fresh

# Start services
make dev-up-fresh

# Run all tests
make test-fresh

# View logs
make logs
```

**Benefits:**
- Works on any machine with Docker
- No need to clone all repos
- Reproducible builds from GitHub

**Uses:** `docker-compose.build.yml` with Dockerfile.github that clones repos during build

---

## Service Endpoints

| Service | Port | URL |
|---------|------|-----|
| Frontend | 3002 | http://localhost:3002 |
| Engine | 3001 | http://localhost:3001 |
| Protocol | 3000 | http://localhost:3000 |
| Remote Script | 9001 | http://localhost:9001 |

## Dependencies

Each service depends on GitHub sources:
- **frontend** → mantra-engine (GitHub)
- **mantra-engine** → musical-intent-protocol (GitHub)
- **protocol** → standalone library
- **remote-script** → standalone (Python mock API)

## Commands Reference

### Local Development
- `make dev-up` - Start services with local source
- `make test` - Run tests in containers
- `make dev-down` - Stop services
- `make logs` - View logs

### Fresh Machine
- `make build-fresh` - Build from GitHub sources
- `make dev-up-fresh` - Start services from GitHub
- `make test-fresh` - Run all tests from GitHub

### Production (Pre-built Images)
- `make build` - Build all locally
- `make build-{protocol,engine,fe,remote}` - Build individual services
- `make deploy` - Push images to GitHub Container Registry

### Utilities
- `make mock-api` - Run mock API server in foreground
- `make clean` - Clean up containers and networks

## Network Architecture

Services communicate over `mantra-network` bridge:

```
Frontend (3002)
    └── depends on
    Engine (3001)
        └── depends on
        Protocol (3000)

Remote Script (9001) - Independent
```

## Environment Variables

**When services start:**
- `ENGINE`: Sets `MIP_PROTOCOL_URL=http://protocol:3000`
- `FRONTEND`: Sets `NEXT_PUBLIC_API_URL=http://engine:3000`

## Health Checks

All services include health checks:
- Interval: 30 seconds
- Timeout: 10 seconds
- Retries: 3
- Start period: 5 seconds

## Workflow: Make Changes → Test → Push

### Local Development Workflow
```bash
# 1. Make changes to any repo
cd ../mantra-engine
# ... edit src/...

# 2. Test in container
cd ../mantra-docker
make test

# 3. Push to GitHub
cd ../mantra-engine
git add .
git commit -m "..."
git push

# 4. Services automatically use latest when rebuilt
```

### CI/CD Workflow (Coming Soon)
GitHub Actions will:
- Run tests on every push
- Build Docker images
- Push to GitHub Container Registry
- Trigger deployments


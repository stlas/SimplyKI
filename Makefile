# SimplyKI Makefile
# Erstellt: 2025-07-24 15:10:00 CEST

.PHONY: all build test install clean docker help

# Default target
all: build

# Build all components
build:
	@echo "🏗️  Building SimplyKI..."
	@echo "Building shell scripts..."
	@chmod +x bin/simplyKI
	@find modules -name "*.sh" -exec chmod +x {} \;
	@echo "Building BrainMemory..."
	@if command -v cargo >/dev/null 2>&1; then \
		cd modules/brainmemory && cargo build --release; \
	else \
		echo "⚠️  Rust not installed, skipping BrainMemory build"; \
	fi
	@echo "✅ Build complete!"

# Run tests
test:
	@echo "🧪 Running tests..."
	@./bin/simplyKI status
	@./bin/simplyKI brain benchmark
	@if [ -f modules/brainmemory/target/release/brainmemory ]; then \
		cd modules/brainmemory && cargo test; \
	fi
	@echo "✅ All tests passed!"

# Install SimplyKI
install:
	@echo "📦 Installing SimplyKI..."
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $(PWD)/bin/simplyKI $(HOME)/.local/bin/ski
	@echo "✅ Installed! Add ~/.local/bin to your PATH"
	@echo "   export PATH=\$$HOME/.local/bin:\$$PATH"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	@find . -name "*.tmp" -delete
	@find . -name "*.log" -delete
	@rm -rf modules/brainmemory/target
	@echo "✅ Clean complete!"

# Docker operations
docker:
	@echo "🐳 Building Docker image..."
	docker build -t simplyKI:latest .

docker-run:
	@echo "🐳 Running SimplyKI in Docker..."
	docker run -it --rm \
		-e ANTHROPIC_API_KEY="$(ANTHROPIC_API_KEY)" \
		-v $(PWD)/projects:/home/simplyKI/projects \
		simplyKI:latest

docker-compose-up:
	@echo "🐳 Starting SimplyKI services..."
	docker-compose up -d

docker-compose-down:
	@echo "🐳 Stopping SimplyKI services..."
	docker-compose down

# Development helpers
dev:
	@echo "👨‍💻 Starting development environment..."
	@tmux new-session -d -s simplyKI || true
	@tmux send-keys -t simplyKI "cd $(PWD) && ./bin/simplyKI status" C-m
	@tmux split-window -t simplyKI -h
	@tmux send-keys -t simplyKI "cd modules/brainmemory && cargo watch -x build" C-m
	@tmux attach -t simplyKI

# Release
release:
	@echo "📦 Creating release..."
	@read -p "Version (e.g., v1.0.0): " version; \
	git tag -a $$version -m "Release $$version" && \
	git push origin $$version

# Help
help:
	@echo "SimplyKI Makefile Commands:"
	@echo ""
	@echo "  make build          - Build all components"
	@echo "  make test           - Run tests"
	@echo "  make install        - Install SimplyKI locally"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make docker         - Build Docker image"
	@echo "  make docker-run     - Run in Docker"
	@echo "  make dev            - Start dev environment"
	@echo "  make release        - Create a new release"
	@echo "  make help           - Show this help"
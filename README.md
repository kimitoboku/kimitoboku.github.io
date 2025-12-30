# kimitoboku.github.io

## Development

### Prerequisites

- Docker
- Docker Compose

### Build and Run

```bash
# Start development server
docker compose up

# Run in background
docker compose up -d

# Stop server
docker compose down
```

The site will be available at http://localhost:4000

Live reload is enabled - changes will automatically refresh the browser.

### Rebuild

```bash
# Rebuild after Gemfile changes
docker compose build --no-cache

# Rebuild and start
docker compose up --build
```

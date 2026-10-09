.PHONY: check dev down e2e

# The one command the Pipeline calls.
check:
	node --test api/*.test.js

# A fresh local stack at the checkout, on http://localhost:3080.
dev:
	docker compose -p rt-local down -v --remove-orphans
	docker compose -p rt-local up -d --build --wait --wait-timeout 60

down:
	docker compose -p rt-local down -v --remove-orphans

# BASE_URL picks the environment; GREP picks the tests.
e2e:
	cd e2e && BASE_URL=$${BASE_URL:-http://localhost:3080} npx playwright test $(if $(GREP),--grep "$(GREP)")

.PHONY: check-formatting
check-formatting:
	@if ! test -z "$$(gofmt -l .)"; then echo "Code is not formatted. Please run gofmt -w ."; exit 1; fi

.PHONY: govet
govet:
	@go vet ./...

.PHONY: lint
lint:
	@golangci-lint run

defaultCodeCoverageMinimum = 20
.PHONY: coverage
coverage:
	@go test -v -coverpkg=./... -coverprofile=profile.cov ./... > /dev/null 2>&1 && \
	grep -v 'interfaces/' profile.cov | sed '/interfaces/d' > profile2.cov && mv profile2.cov profile.cov && \
	grep -v 'mocks/' profile.cov | sed '/mocks/d' > profile2.cov && mv profile2.cov profile.cov && \
	grep -v 'main.go' profile.cov | sed '/main.go/d' > profile2.cov && mv profile2.cov profile.cov && \
	percentage=$$(go tool cover -func profile.cov | grep -o 'total:.*' | grep -o '[0-9.]\+%' | awk -F'.' '{print $$1}' | tr -d '%') && \
	rm profile.cov && \
	echo "$$percentage" | awk -v expected="$${codeCoverageMinimum:-$(defaultCodeCoverageMinimum)}" '{ if ($$1 >= expected) { print "Code coverage is", $$1 "%", "which matches or exceeds the required level of", expected "%"; } else { print "Code coverage falls below the requirement. Coverage must be at least", expected "%", "but is only", $$1 "%"; exit 1; } }'

.PHONY: test
test:
	@go test ./...
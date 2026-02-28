.PHONY: run build test tidy clean

run:
	go run .

build:
	CGO_ENABLED=0 go build -o bin/server .

test:
	go test ./...

tidy:
	go mod tidy

clean:
	rm -rf bin/

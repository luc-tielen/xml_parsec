
build:
	mix compile

clean:
	mix clean

test:
	mix test.watch

lint:
	mix credo --strict

.PHONY:  build clean test lint

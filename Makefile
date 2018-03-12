
build:
	mix compile

clean:
	mix clean

test:
	mix test.watch

lint:
	mix credo --strict

dialyzer:
	mix dialyzer

.PHONY:  build clean test lint


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

docs:
	mix docs

coverage:
	mix coveralls.detail

.PHONY:  build clean test lint dialyzer docs coverage

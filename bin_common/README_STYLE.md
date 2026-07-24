# Python Script Style

Use these conventions for small Python command-line tools and automation scripts
in this directory.

## Use the standard library

Prefer Python's standard library. Do not add a dependency when `argparse`,
`dataclasses`, `json`, `pathlib`, `subprocess`, `typing`, or `unittest` already
solves the problem clearly.

If you strongly believe a third party library is necessary, you need to ask me first

## Model data with types

Prefer `typing.NamedTuple` for small immutable records and `dataclasses` for
records that benefit from defaults, methods, or richer behavior. Avoid passing
unstructured dictionaries through the program. Dictionaries are reasonable at
I/O boundaries, such as immediately after parsing JSON, but convert them to a
typed model promptly.

```python
from dataclasses import dataclass
from typing import NamedTuple


class InputEvent(NamedTuple):
    name: str
    count: int


@dataclass(frozen=True)
class Result:
    message: str
    should_write: bool = True
```

## Separate I/O from computation

Keep parsing, decisions, and transformations in pure functions when possible.
Put filesystem, network, environment, and subprocess access in small,
descriptively named functions. This makes behavior easier to understand and
test without mocks.

`main()` should read like an outline of the program:

```python
def calculate_result(event: InputEvent) -> Result:
    message = f"{event.name}: {event.count + 1}"
    return Result(message=message)


def main() -> None:
    event = read_event()                 # I/O
    result = calculate_result(event)     # Pure computation
    write_result(result)                 # I/O
```

Keep external data at the edges:

```python
import json
import sys
from typing import Any


def parse_event(raw: str) -> InputEvent:
    value: Any = json.loads(raw)
    if not isinstance(value, dict):
        raise ValueError("expected a JSON object")
    name = value.get("name")
    count = value.get("count")
    if not isinstance(name, str) or not isinstance(count, int):
        raise ValueError("name must be a string and count must be an integer")
    return InputEvent(name=name, count=count)


def read_event() -> InputEvent:
    return parse_event(sys.stdin.read())
```

## Keep tests inline

For single-file tools, keep focused `unittest` tests in the same file and expose
them through a `--test` argument. Import test-only modules inside `run_tests()`
so normal execution stays lightweight.

```python
import sys


def run_tests() -> int:
    import unittest

    class CalculationTests(unittest.TestCase):
        def test_increments_count(self) -> None:
            result = calculate_result(InputEvent("jobs", 2))
            self.assertEqual(result, Result("jobs: 3"))

    suite = unittest.defaultTestLoader.loadTestsFromTestCase(CalculationTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    if sys.argv[1:] == ["--test"]:
        raise SystemExit(run_tests())
    main()
```

Test pure functions directly. Add narrowly scoped I/O tests only for important
behavior such as subprocess timeouts, atomic writes, or fallback handling.

## General preferences

- Use explicit names and return types.
- Prefer immutable models (`NamedTuple` or `@dataclass(frozen=True)`).
- Keep functions small and responsible for one operation.
- Surface malformed input with a clear error; do not silently invent success.
- Bound subprocess and network operations with explicit timeouts.
- Keep `main()` orchestration-only whenever practical.

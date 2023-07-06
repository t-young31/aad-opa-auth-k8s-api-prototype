#!/usr/bin/env python3
import sys
import yaml

from pathlib import Path
from typing import List


def add_key_value_pairs(chunk: dict, pairs: List[tuple]) -> None:
    for key, value in chunk.items():
        if isinstance(value, dict):
            sub_chunk = {f"{key.upper()}_{k.upper()}": v for k, v in value.items()}
            add_key_value_pairs(sub_chunk, pairs)
        else:
            pairs.append((key.upper(), value))


def print_key_value_pairs(filepath: Path) -> None:
    with open(filepath, "r") as config_file:
        config = yaml.safe_load(config_file)

    pairs: List[tuple] = []
    add_key_value_pairs(config, pairs)

    print("\n".join(f"{k}={v}" for k, v in pairs))


def main() -> None:
    filepath = Path(sys.argv[1])
    assert filepath.exists()

    print_key_value_pairs(filepath)


if __name__ == "__main__":
    main()

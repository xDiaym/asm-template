#!/usr/bin/env python3
from pathlib import Path
from typing import TypedDict
import matplotlib
import matplotlib.pyplot as plt
from argparse import ArgumentParser
import io
import sys
import subprocess
from csv import DictReader

root = Path(__file__).resolve().parent.parent

sys.path.append(str(root / 'config'))
from graph import f, FROM, TO  # type: ignore


class Tabulature(TypedDict):
    x: list[float]
    f: list[float]


# FIXME: rename
def tabulate(args: list[str]) -> int:
    with subprocess.Popen(args, stdout=subprocess.PIPE) as proc:
        stdout = proc.communicate()[0].decode()
    return stdout


def generate_exact(step: float) -> Tabulature:
    n = int((TO - FROM) / step) + 1
    tab = {"x": [], "f": []}
    x0 = FROM
    
    for i in range(n):
        tab["x"].append(x0)
        try:
            tab["f"].append(f(x0))
        except ValueError:
            tab["f"].append(float('nan'))
        x0 += step

    return tab

def read_csv(fp: io.FileIO) -> Tabulature:
    reader = DictReader(fp)
    mapping = {"x": [], "f": []}
    for line in reader:
        mapping["x"].append(float(line["x"]))
        mapping["f"].append(float(line["f"]))
    return mapping


def plot(asm: Tabulature, exact: Tabulature, interactive: bool) -> None:
    plt.plot(asm["x"], asm["f"], label="asm")
    plt.plot(exact["x"], exact["f"], label="exact")
    plt.legend()

    # FIXME:
    # if interactive:
    #     plt.show()
    # else:
    #     plt.savefig("example.png")
    plt.savefig("../example.png")


def run(exe: Path, step: float, interactive: bool = False) -> None:
    stdout = tabulate([exe, str(step)])
    asm = read_csv(io.StringIO(stdout))
    exact = generate_exact(step)
    plot(asm, exact, interactive)


def main() -> int:
    parser = ArgumentParser()
    parser.add_argument("exe", type=Path)
    # TODO: outfle in non-interactive mode
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-s", "--step", type=float)
    group.add_argument("-i", "--interactive", action="store_true")
    args = parser.parse_args()

    step = float(input("step> ")) if args.interactive else args.step
    run(args.exe, step, args.interactive)

    return 0


if __name__ == "__main__":
    sys.exit(main())

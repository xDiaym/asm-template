#!/usr/bin/env python3
from collections.abc import Callable
from dataclasses import dataclass
from functools import wraps
from pathlib import Path
from typing import TypedDict
import matplotlib
import matplotlib.pyplot as plt
from argparse import ArgumentParser
import io
import sys
import subprocess
from csv import DictReader

from config import FROM, TO, STEP, f


ROOT = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT / "config"
PLOT_OUT_PATH = ROOT / "plot"
PLT_BACKEND = "QtAgg"

PLOT_OUT_PATH.mkdir(parents=True, exist_ok=True)


def use_nan(func: Callable[[float], float]) -> Callable[[float], float]:
    @wraps(func)
    def wrapper(x: float) -> float:
        try:
            return func(x)
        except ValueError:  # type: ignore
            return float("nan")

    return wrapper


class Tabulature(TypedDict):
    x: list[float]
    f: list[float]


@dataclass
class Config:
    from_: float
    to: float
    step: float
    f: Callable[[float], float]

    @property
    def iters(self) -> int:
        return int((self.to - self.from_) / self.step) + 1


def run_lab(args: list[str]) -> int:
    with subprocess.Popen(args, stdout=subprocess.PIPE) as proc:
        stdout = proc.communicate()[0].decode()
    return stdout


def read_csv(fp: io.FileIO) -> Tabulature:
    reader = DictReader(fp)
    mapping = {"x": [], "f": []}
    for line in reader:
        mapping["x"].append(float(line["x"]))
        mapping["f"].append(float(line["f"]))
    return mapping


def generate_exact(config: Config) -> Tabulature:
    tab = {"x": [], "f": []}
    x0 = config.from_

    for i in range(config.iters):
        tab["x"].append(x0)
        tab["f"].append(config.f(x0))
        x0 += config.step

    return tab


def plot(
    asm: Tabulature, exact: Tabulature, interactive: bool, config: Config
) -> None:
    if interactive:
        matplotlib.use(PLT_BACKEND)

    plt.plot(asm["x"], asm["f"], label="asm")
    plt.plot(exact["x"], exact["f"], label="exact")
    plt.title(f"$dx = {config.step}$")
    plt.legend()

    if interactive:
        plt.show()
    else:
        plt.savefig(PLOT_OUT_PATH / "plot.png")


def run(exe: Path, interactive: bool, config: Config) -> None:
    stdout = run_lab([exe, str(config.step)])
    asm = read_csv(io.StringIO(stdout))
    exact = generate_exact(config)
    plot(asm, exact, interactive, config)


def main() -> int:
    parser = ArgumentParser()
    parser.add_argument("exe", type=Path)
    parser.add_argument("-s", "--step", type=float, default=None)
    parser.add_argument("-i", "--interactive", action="store_true")
    args = parser.parse_args()

    config = Config(from_=FROM, to=TO, step=STEP, f=use_nan(f))
    config.step = args.step or config.step

    try:
        run(args.exe, args.interactive, config)
    except Exception as exc:
        print(exc)
        return -1
    return 0


if __name__ == "__main__":
    sys.exit(main())

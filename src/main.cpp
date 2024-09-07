#include <format>
#include <iostream>

extern "C" float f(float);  // NOLINT

static constexpr float kStart = -1.0f;
static constexpr float kEnd = 1.0f;

void GenerateCSVReport(float dh, std::size_t n) {
  float x = kStart;
  std::cout << "x,f\n";
  for (std::size_t i = 0; i < n; ++i) {
    std::cout << std::format("{},{}\n", x, f(x));
    x += dh;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) {
    std::cout << std::format("usage: {} <step>\n", argv[0]);
    return -1;
  }

  const auto dh = std::atof(argv[1]);
  const auto n = static_cast<std::size_t>((kEnd - kStart) / dh) + 1;

  GenerateCSVReport(dh, n);

  return 0;
}

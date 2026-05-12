<div align="center">

# asdf-llvm [![Build](https://github.com/higebu/asdf-llvm/actions/workflows/build.yml/badge.svg)](https://github.com/higebu/asdf-llvm/actions/workflows/build.yml) [![Lint](https://github.com/higebu/asdf-llvm/actions/workflows/lint.yml/badge.svg)](https://github.com/higebu/asdf-llvm/actions/workflows/lint.yml)

[llvm](https://llvm.org/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# The Difference Between This And [mise-llvm](https://github.com/mise-plugins/mise-llvm)

[mise-llvm](https://github.com/mise-plugins/mise-llvm) compiles from source and only installs clang, clang, clang-cl, and clang-cpp, whereas this repository prefers to download precompiled versions and installs the entire LLVM.

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- [Ninja](https://ninja-build.org/): for build clang.

# Install

Plugin:

```shell
asdf plugin add llvm https://github.com/Koracan/mise-full-llvm.git
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/higebu/asdf-llvm/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Yuya Kusakabe](https://github.com/higebu/)

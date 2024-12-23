# project-unnamed

-----

## Table of Contents

- [License](#license)
- [About](#about)
- [Setting up dev-env](#setting-up-dev-env)
    - [Linux](#linux)
    - [Windows](#windows)
- [Potential ideas](#potential-ideas)
- [Documentation system](#documentation-system)
    - [How to run](#how-to-run)

## License

`project-unnamed` is distributed under the terms of the [MIT](https://spdx.org/licenses/MIT.html) license.

## About
Current project ideas that sound fun to make with friends

## Setting up dev-env

The development environment is set up best through **nix**. This allows all of us to have the same environment. There are some rules though, so see below:

### Linux
* Install [nix](nixos.org/download) through their recommended process and for **multi-user installation** (if you do not want to do this, do single, but it's recommended to be multi-user).
    ```bash
     sh <(curl -L https://nixos.org/nix/install) --daemon
    ```
* **Optional**: Install devenv
    * This allows for the environment to auto be setup once you enter the directory
* Afterwards, from the directory, run `nix develop -c ${SHELL}`, or whatever shell of choice

### Windows
* Install `wsl`, make sure that you do version 2 as it has more supported features
* Follow the [Linux](#linux) installation using wsl
> [!NOTE]
> If you do not want to set up the environment and would rather install directly, on windows, here is the list of packages that are being used:
> * zig version 0.13.0
> * python 3.12 (currently only has ipython)
> * gcc version 13.2.0
> * doxygen version 1.10.0
> * doxypypy version 0.8.8.7

## Potential ideas
1. Rest api using C++ and Python
2. Dotfile management system using syntax similar to that of autogen, example of file that is used to generate the actual config file
    ```toml
    [system]
    install-directory = @HOME-DIR@ # Home dir is either configured from a command line,
                                   # environment variable, or config file of tool
    ```
3. Process manager
    * Similar to init system?
4. API for watching syscalls from kernel (or WM_COMMANDS on windows I believe?)

Project chosen:
- [ ] Rest api
- [ ] Dotfile management
- [ ] Process manager
- [ ] API for syscalls

## Documentation system

The documentation system is mainly going to be done through `doxygen`. Zig's should do it itself, but if needbe it's just going through the ast, which zig should already create, and we can create a walker for it if need be.

### How to run
The documentation is ran through `zig`. In order to generate html documentation, please run
```bash
zig build docs
```
The generaed documentation will be in the local **html** directory.

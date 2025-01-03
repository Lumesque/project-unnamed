# project-unnamed

-----

## Table of Contents

- [License](#license)
- [About](#about)
- [Setting up dev-env](#setting-up-dev-env)
    - [Linux](#linux)
    - [Windows](#windows)
        - [Enabling Visual Studio With Wsl](#enabling-visual-studio-with-wsl)
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
* Install nix
    * Without systemd support
    ```bash
    $ curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
    ```
    * With systemd support
    ```bash
    $ curl -L https://nixos.org/nix/install | sh -s -- --daemon
    ```
* **Optional**: Install devenv
    * This allows for the environment to auto be setup once you enter the directory
* Afterwards, from the directory, run `nix develop -c ${SHELL}`, or whatever shell of choice

> [!NOTE]
> If you do not want to set up the environment and would rather install directly, on windows, here is the list of packages that are being used:
> * zig version 0.13.0
> * python 3.12 (currently only has ipython)
> * gcc version 13.2.0
> * doxygen version 1.10.0
> * doxypypy version 0.8.8.7

#### Enabling Visual Studio With Wsl
In order to enable visual studio with wsl, please refer to the following [tutorial](https://code.visualstudio.com/docs/remote/wsl-tutorial) for setup.

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
5. TUI/Rest api for h5 data tables, a way to display the data in real time consistently
    * One of the goals I'd really like to do with this is make it so that it routinely updates, like when you add something to the table, the display will change. In essense, 'states' from svelte, react, or refs from vue
        * This would potentially just be a monitor call on a fd, something that both windows and linux should support out of the box with `poll` and likewise events, but otherwise there are third party libs like `inotify`
6. TUI application for displaying graphs given two numbers, this is meant to be similar to the command line graph display but take advantage of protocols in more modern terminals to allow for displaying them correctly
7. Some form of profiling, either a thread profiler or a generic one
    * Originating in C/C++?
    * Otherwise, I'd also very much like to make a profiler to 'watch' a variable, and dictate when it changes. This most likely can be done easily in python by overwriting the variable with a wrapper of some sort, similar to a mock function.
8. AST Analyzer
    * This is essentially for watching one piece of code, and then seeing the possibilities ONLY when that variable _can_ change. So for instance, if you had this
    ```python
    def function(value: str):
        x: int = random.randint(5)
        if (x > 2):
            value = "test"
        else:
            value = "other"

        for (_ in range(5)):
            pass
        return value
    ```
    * Essentially, the graph would end up semi-looking like this (with an option added later to remove non-side effective functions for the specific variable)
    ```bash
    if (stmt)
    |- Variable changed
    for (stmt)
    | - return
    ```
    * This would be done in Python using AstNodeWalkers most likely, but we could also develop something in C/C++ with the help of some of either the python libs or general parsing.

Project chosen:
- [ ] Rest api
- [ ] Dotfile management
- [ ] Process manager
- [ ] API for syscalls
- [ ] TUI/REST api for H5 data tables
- [ ] TUI application for graphing in terminal
- [ ] Profiling tool
- [ ] AST Analyzer

## Documentation system

The documentation system is mainly going to be done through `doxygen`. Zig's should do it itself, but if needbe it's just going through the ast, which zig should already create, and we can create a walker for it if need be.

### How to run
The documentation is ran through `zig`. In order to generate html documentation, please run
```bash
zig build docs
```
The generaed documentation will be in the local **html** directory.

# Compiling

Below are steps to compiling WTF Engine. Y'know like the requirements and all that. Just know that the engine has only been tested on Windows. A command prompt is needed in order to follow the steps below.

## Setup

1. Install [Haxe](https://haxe.org/download).
2. Install [Git](https://www.git-scm.com).
3. Run `git clone https://github.com/realvirtu/WTF-Engine.git` from the folder where you want to store the repository.
4. Run `cd WTF-Engine`.
5. Run `haxelib --global install hmm` and `haxelib --global run hmm setup`.
6. Run `hmm install`.
7. Run `haxelib run lime setup`.
8. Run `lime rebuild windows`. You may have to run this command again whenever the Lime dependency gets updated.

> [!NOTE]
> If dependencies need updating, run `hmm install`.

## Platform Setup

Windows:

1. Install [Visual Studio Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe).
2. Select "Individual Components" when prompted during the Build Tools installation process and install the following:
    - MSVC v143 VS 2022 C++ x64/x86 build tools.
    - Windows 10/11 SDK.

## Compiling

- Run `lime test <platform>` to compile the engine.
- Run `lime run <platform>` if you want to relaunch the engine.
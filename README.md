# jenv for Windows

jenv is a tool to manage Java Environment

## What's jenv ?

This is an updated fork of `jenv`, a beloved Java environment manager adapted from `rbenv`.

`jenv` gives you a few critical affordances for using `java` on development machines:

- It lets you switch between `java` versions. This is useful when developing Android applications, which generally require Java 8 for its tools, versus server applications, which use later versions like Java 11.
- It sets `JAVA_HOME` inside your shell, in a way that can be set globally, local to the current working directory or per shell.

### Contents

1. [Getting Started](#1-getting-started)

## Installation

### Get jenv-win

- **With zip file**

  1. Download link: [jenv-win](https://github.com/hanlimin/jenv-win/archive/master.zip)
  2. Create a `.jenv` directory if not exist under `$HOME` or `%USERPROFILE%`
  3. Extract and move files to

     - Powershell or Git Bash: `$HOME/.jenv/`
     - cmd.exe: `%USERPROFILE%\.jenv\`

  4. Ensure you see `bin` folder under `%USERPROFILE%\.jenv\jenv-win`

- **With Git**
  - Powershell or Git Bash: `git clone https://github.com/hanlimin/jenv-win.git "$HOME/.pyenv"`
  - cmd.exe: `git clone https://github.com/hanlimin/jenv-win.git "%USERPROFILE%\.pyenv"`

### Finish the installation

1. Add JENV to your Environment Variables
   Using either PowerShell run

   ```powershell
   cd $HOME/.jenv/
   ./install.bat
   ```

2. Close and reopen your terminal app and run `jenv --version`

3. Run `pyenv` to see list of commands it supports

## Usage

### 1.Lists all Java versions

```powershell
> jenv versions
1.5.0_22
1.6.0_45
1.7.0_80
1.8.0_271
*11.0.9(set by /Users/user/.jenv/version)
```

### 2.Setting a Global Java Version

```powershell
> jenv global 1.8.0_271
```

### 3.Setting a Local Java Version

```powershell
> jenv local 1.7.0_80
```

### 4.Setting a Shell Java Version

```powershell
> jenv shell 1.5.0_22
```

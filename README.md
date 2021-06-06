# Console-git-wrapper
Simple console git client wrapper. It script for wrap git commands and quickly exec him.

![Screenshot](https://github.com/ta-tikoma/console-git-wrapper/raw/master/screenshot.png)

# Install
1. Clone repository.
2. Add path to repository folder to PATH.
3. Open cmd, go to any repository folder with `.git`.
4. Run command `cgw`.

# Commands
  
| Short     | Description |
| --- | --- |
| *Base*    | |
| s         | show `s`tatus  |
| c         | `c`ommit all changed files  |
| p         | `p`ush to current branch  |
| cp        | `c`ommit all changed files and `p`ush to current branch  |
| pl        | `p`u`l`l form current branch  |
| f         | `f`etch  |
| ff        | `f`etch `f`orce  |
| *Branch*  | |
| m         | `m`erge selected branch in current  |
| m+        | `m`erge remote branch in current  |
| b         | `b`ranch list |
| b+        |  remote `b`ranch list |
| rnb       | `r`e`n`ame current `b`ranch|
| cb        | `c`hange `b`ranch   |
| cb+       | `c`hange on remote `b`ranch   |
| db        | `d`elete `b`ranch  |
| db+       | `d`elete remote `b`ranch  |
| ab        | `a`dd `b`ranch  |
| bfc       | `b`ranch `f`rom `c`ommit  |
| bh        | current `b`ranch `h`istory|
| bp        | `b`ranch remote `p`rune origin |
| *Commit*  | |
| rc        | `r`evert `c`ommit  |
| *Tag*     | |
| t         | `t`ag list  |
| ftf       | `f`etch `t`ag `f`orce |
| dt        | `d`elete `t`ag  local and remote|
| at        | `a`dd `t`ag on last commit local and remote|
| mt        | re`m`ove `t`ag from old commit and add to current |
| *Other*   | |
| cf        | `c`heckout `f`ile  |
| r         | hard `r`eset branch  |
| *Program* | |
| h         | `h`elp  |
| e         | `e`xit  |

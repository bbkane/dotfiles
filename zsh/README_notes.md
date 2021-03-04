# Finding stuff that got added to the PATH

(Looking at you `/usr/local/go/bin` from Go installer)

Zsh sources files in this order (from [Medium](https://medium.com/@rajsek/zsh-bash-startup-files-loading-order-bashrc-zshrc-etc-e30045652f2e)):


|                 | Interactive login   | Interactive non-login   | Script |
|-----------------|:-------------------:|:-----------------------:|:--------:|
| /etc/zshenv     |    A                |    A                    |  A       |
| ~/.zshenv       |    B                |    B                    |  B       |
| /etc/zprofile   |    C                |                         |          |
| ~/.zprofile     |    D                |                         |          |
| /etc/zshrc      |    E                |    C                    |          |
| ~/.zshrc        |    F                |    D                    |          |
| /etc/zlogin     |    G                |                         |          |
| ~/.zlogin       |    H                |                         |          |
| ~/.zlogout      |    I                |                         |          |
| /etc/zlogout    |    J                |                         |          |


In particular, `/etc/zprofile` `eval`'s `/usr/libexec/path_helper`. Running
`strings /usr/libexec/path_helper` shows that it references `/etc/paths` and
`/etc/paths.d`. And `/etc/paths.d` where I found my wild `go` PATH!!


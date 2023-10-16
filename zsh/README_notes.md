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

# Profiling

There's a couple different options to profile, but I found [How to profile your zsh startup time – Benjamin Esham](https://esham.io/2018/02/zsh-profiling) to be my favorite.

I started with:

```
$ time  zsh -i -c exit
Logging to zsh_profile.RXqBu5Oi
zsh -i -c exit  1.59s user 1.15s system 99% cpu 2.763 total
```

Almost 3 seconds to launch zsh!!!

```bash
~/sort_timings.zsh ./zsh_profile.RXqBu5Oi > zsh_profile.RXqBu5Oi.txt
```

I then read through the logs and removed the `volta` lines and the `zsh-autocompletion` lines and ended up with:

```
21:12:11.888 PDT mac02:~/tmp/zsh_timings
$ time zsh -i -c exit
Logging to zsh_profile.QlcgTdvJ
zsh -i -c exit  0.69s user 0.52s system 99% cpu 1.215 total
21:15:33.363 PDT mac02:~/tmp/zsh_timings
$ time zsh -i -c exit
Logging to zsh_profile.poaZyKny
zsh -i -c exit  0.12s user 0.11s system 98% cpu 0.226 total
21:15:47.473 PDT mac02:~/tmp/zsh_timings
```

After caching, 0.23 seconds, which is much better.


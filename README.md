# Mullvad Split Tunneling

*A better split tunneling for Mullvad VPN on Linux, using Mullvad CLI and Bash*
<BR>

**⚠️ you will need Mullvad installed ⚠️**<br><br>

did this because i dont wanna use the other methods that are very shitty

is the excluded-apps file is empty, it will open for you in code
add the apps to the excluded-apps file (1 app, 1 line)

## Installation:

- Clone the repository:
```sh
git clone https://github.com/Soyoudv/mullvad-st.git && cd mullvad-st
```

- Install with the makefile:
```sh
make install
```

- Run with
```sh
mst
```

## Options:

`-s`
*silenced mode*

`-a` + `(app name)`
*adds a given entry to the excluded-apps file* <br>
*(can be added without closing the program with another terminal instance)*

`-r` + `(app name)`
*removes a given entry to the excluded-apps file* <br>
*(can be removed without closing the program with another terminal instance)*

`l`
*show the excluded apps list*

`e`
*open the excluded apps file*<br>
*(can be modified without closing the program with another terminal instance)*
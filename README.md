# PAM TouchID

This project contains a PAM authentication module using TouchID for macOS.
That way you can use TouchID for authentication with e.g. `sudo`.

## Installation

To add TouchID support to `sudo` first build and install the project:

```sh
make
sudo make install
```

Then edit `/etc/pam.d/sudo` using root rights with any editor and add the following as the first line:

```
auth sufficient pam_touchid.so
```

You may further add a `reason` parameter, to overwrite the message shown, like this:

```
auth sufficient pam_touchid.so "reason=execute a command as root"
```

**Do not** remove any of the preexisting lines in the file though.

If you use e.g. `vim` you might see a warning about the file being readonly, but you can still safely overwrite the file using the force flag `!`.

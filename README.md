# mobileconfig generation script for Chrome-based browsers on macOS

This script generates a `.mobileconfig` file for Chrome-based browsers on macOS to override `ExtensionInstallAllowlist` and allow installation of (whitelisted) extensions using `.crx` file.

## Usage
To generate a new `.mobileconfig` file, run the main script without any arguments:
```sh
./generate.sh
```

To add a new extension to the whitelist, run the main script with the existing `.mobileconfig` as an argument, example:
```sh
./generate.sh com.brave.Browser.mobileconfig
```

## Examples
### Creating a new `.mobileconfig` file
```sh
❯ ./generate.sh
Enter browser name (Chrome, Edge, Brave): Brave
Enter extension ID (separated by space): asdfhsadjkfhdskj saddsafdsafas sahdfkjshfkas
❯ cat com.brave.Browser.mobileconfig
```
Install the generated `.mobileconfig` profile as normal

### Adding a new extension to an existing `.mobileconfig` file
```sh
❯ ./generate.sh com.brave.Browser.mobileconfig
Existing extension IDs from com.brave.Browser.mobileconfig, copy to next prompt to preserve:
asdfhsadjkfhdskj saddsafdsafas sahdfkjshfkas
Enter extension ID (separated by space): asdfhsadjkfhdskj saddsafdsafas sahdfkjshfkas dfasjfhaskjfajsf
```
Reinstall the modified `.mobileconfig` profile/delete the old one and reinstall.
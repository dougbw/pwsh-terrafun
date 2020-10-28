# What
This is a PowerShell terraform wrapper for managing terraform versions. It enables seemless switching between different terraform versions.

# Features
* terraform version management

# Installation
The module can be installed from the from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Terrafun/).

Supported platforms:
* Windows
* Linux
* MacOs

```
Install-Module terrafun
```

# Use from PowerShell
Import the module and simply run `tf` instead of `terraform`
```
Import-Module terrafun
tf
```

# Use from other shells
As long as you have PowerShell installed on your machine, you can use this through other shells (bash, zsh, etc) through aliases.
```
pwsh -c "if (Get-Module terrafun -ListAvailable){Update-Module -Force terrafun}else{Install-Module -Force terrafun}"
echo 'alias tf="pwsh -wd $(pwd) -c tf"' > ~/.bashrc
echo 'alias tf="pwsh -wd $(pwd) -c tf"' > ~/.zshrc
```

# Set the terraform version in your user profile
Use the `tf version {version} global` command which will store the version infomation in a config file within your user profile: `~/.terraform-version/config.json`
```
tf version 0.13.5 global
```

# Set the terraform version for the current directory
Use the `tf version {version}` command
```
tf version 0.13.5
```

The version infomation will be written into a **.terraform-version** file into the current directory and this takes precedence over the user profile configuration.

```
PS /tmp/foo> cat .terraform-version
0.12.15
PS /tmp/foo> tf version
Terraform v0.12.15
PS /tmp/foo> cd ../bar
PS /tmp/bar> cat .terraform-version
0.12.19
PS /tmp/bar> tf version
Terraform v0.12.19
```

## List available versions
Use the `tf version list` command
```
tf version list
```

# Binary install location
Binaries are downloaded to...
```
 ~/.terraform-version/terraform\_{version}\_{platform}\_{arch}/terraform(.exe)
```
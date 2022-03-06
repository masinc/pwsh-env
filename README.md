# pwsh-env

The repository is an environment repository for pwsh (PowerShell Core).

## Installation

Some software must be installed.


### Add to pwsh profile

After cloning this repository, add the following to the pwsh Profile.  
Change `<<PWSH-ENV PATH>>` to the repository path.

```ps1
if ( $PSVersionTable.PSEdition -eq "Core" ) {
    . <<PWSH-ENV PATH>>\init.ps1
}
```

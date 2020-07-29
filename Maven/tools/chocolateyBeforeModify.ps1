$ErrorActionPreference = 'Stop'
$version = '3.6.3'
$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
$package = Split-Path $toolsDir
$installFolder = "apache-maven-$version"

# Delete current version before upgrading or uninstalling
Remove-Item "$(Join-Path $package $installFolder)" -Force -Recurse

# Clean Environment variables 
[Environment]::SetEnvironmentVariable('M2_HOME', $null, 'Machine')

# Using registry method prevents expansion (and loss) of environment variables (whether the target of the removal or not)
# To avoid bad situations - does not use substring matching or regular expressions
# Removes duplicates of the target removal path, Cleans up double ";", Handles ending "\"
$pathToRemove = Join-Path '%M2_HOME%' 'bin'

try {
    $regKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
    $unexpandedPath = $regKey.GetValue('Path', $null, 'DoNotExpandEnvironmentNames')

    foreach ($path in "$unexpandedPath".split(';')) {
        if ($pathToRemove -ine $path -and "$pathToRemove\" -ine $path) {
            [string[]]$newpath += "$path"
        }
    }
    $assembledNewPath = ($newpath -join (';')).trimend(';')

    $regKey.SetValue("Path", $assembledNewPath, "ExpandString")
}
finally {
    $regKey.Dispose()
}

$tools = Split-Path $MyInvocation.MyCommand.Definition
$package = Split-Path $tools

# Delete leftovers from previous versions
Remove-Item "$(Join-Path $package 'apache-maven-*')" -Force -Recurse

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
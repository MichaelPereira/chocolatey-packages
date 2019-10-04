#cmd> mvn -version

#create folder if not exists
function CreateFolder ([string]$Path) {
  New-Item -Path $Path -type directory -Force
}

$version = '3.6.2'
$name = "apache-maven-$version"
$tools = Split-Path $MyInvocation.MyCommand.Definition
$package = Split-Path $tools
$m2_home = Join-Path $package $name
$m2_repo = Join-Path $env:USERPROFILE '.m2'
$pathToAdd = Join-Path '%M2_HOME%' 'bin'

$url = "https://archive.apache.org/dist/maven/maven-3/$version/binaries/$name-bin.zip"

# Delete leftovers from previous versions
# TODO: moved to chocolateyBeforeModify.ps1 on v3.6.2. Remove from next release
Remove-Item "$(Join-Path $package 'apache-maven-*')" -Force -Recurse
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

Install-ChocolateyZipPackage `
    -PackageName 'Maven' `
    -Url $url `
    -Checksum '4bb0e0bb1fb74f1b990ba9a6493cc6345873d9188fc7613df16ab0d5bd2017de5a3917af4502792f0bad1fcc95785dcc6660f7add53548e0ec4bfb30ce4b1da7' `
    -ChecksumType 'sha512' `
    -UnzipLocation $package

CreateFolder($m2_repo)

[Environment]::SetEnvironmentVariable('M2_HOME', $m2_home, 'Machine')
Install-ChocolateyPath -PathToInstall $pathToAdd -PathType 'Machine'
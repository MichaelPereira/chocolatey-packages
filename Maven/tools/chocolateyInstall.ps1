#cmd> mvn -version

#create folder if not exists
function CreateFolder ([string]$Path) {
  New-Item -Path $Path -type directory -Force
}

$version = '3.6.3'
$checksum = "1c095ed556eda06c6d82fdf52200bc4f3437a1bab42387e801d6f4c56e833fb82b16e8bf0aab95c9708de7bfb55ec27f653a7cf0f491acebc541af234eded94d"
$name = "apache-maven-$version"
$tools = Split-Path $MyInvocation.MyCommand.Definition
$package = Split-Path $tools
$m2_home = Join-Path $package $name
$m2_repo = Join-Path $env:USERPROFILE '.m2'
$pathToAdd = Join-Path '%M2_HOME%' 'bin'

$url = "https://archive.apache.org/dist/maven/maven-3/$version/binaries/$name-bin.zip"

Install-ChocolateyZipPackage `
    -PackageName 'Maven' `
    -Url $url `
    -Checksum $checksum `
    -ChecksumType 'sha512' `
    -UnzipLocation $package

CreateFolder($m2_repo)

[Environment]::SetEnvironmentVariable('M2_HOME', $m2_home, 'Machine')
Install-ChocolateyPath -PathToInstall $pathToAdd -PathType 'Machine'
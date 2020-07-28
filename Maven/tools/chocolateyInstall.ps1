﻿#cmd> mvn -version
$ErrorActionPreference = 'Stop'
$version = '3.6.3'
$name = "apache-maven-$version"
$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
$package = Split-Path $toolsDir
$m2_home = Join-Path $package $name
$m2_repo = Join-Path $env:USERPROFILE '.m2'
$pathToAdd = Join-Path '%M2_HOME%' 'bin'

New-Item -Path $m2_repo -Type directory -Force

[Environment]::SetEnvironmentVariable('M2_HOME', $m2_home, 'Machine')
Install-ChocolateyPath -PathToInstall $pathToAdd -PathType 'Machine'

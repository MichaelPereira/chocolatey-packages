﻿$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

# Clean Environment variables 
Uninstall-M2PathFromRegistry
Uninstall-M2EnvVar
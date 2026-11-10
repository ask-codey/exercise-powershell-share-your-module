# Checks that RecipeBox is ready to share: its version and manifest, its README, its LICENSE, and the package you
# published into practice-repo. To test the package, it unzips a copy into a throwaway folder that Pester makes and
# removes (TestDrive) and loads RecipeBox from there, the way a friend would after installing it.
# It never registers a repository or installs anything.
# Run it from this folder with: Invoke-Pester .\Check.Tests.ps1   (plain Invoke-Pester runs your own tests too)
# You don't need to change this file.

BeforeAll {
    $script:manifest = Join-Path $PSScriptRoot 'RecipeBox\RecipeBox.psd1'
    $script:readme = Join-Path $PSScriptRoot 'RecipeBox\README.md'
    $script:license = Join-Path $PSScriptRoot 'RecipeBox\LICENSE'
    $script:package = Join-Path $PSScriptRoot 'practice-repo\RecipeBox.1.1.0.nupkg'
    $script:testData = Join-Path $PSScriptRoot 'test-data\recipes.json'

    $script:data = $null
    if (Test-Path -LiteralPath $manifest) {
        $script:data = Import-PowerShellDataFile -Path $manifest
    }

    # Unzips the package into its own folder in TestDrive once, for the package tests.
    $script:unpacked = $null
    if (Test-Path -LiteralPath $package) {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $script:unpacked = Join-Path $TestDrive ('package-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
        [System.IO.Compression.ZipFile]::ExtractToDirectory($package, $unpacked)
    }
}

AfterAll {
    Remove-Module -Name RecipeBox -ErrorAction SilentlyContinue
}

Describe 'Exercise: Share Your Module' {

    Context 'The version and the new command' {

        It '1) the manifest says version 1.1.0' {
            $data | Should -Not -BeNullOrEmpty -Because 'RecipeBox\RecipeBox.psd1 should be here. Get a fresh copy from the exercise repo if it is gone'
            $data.ModuleVersion | Should -Be '1.1.0' -Because 'Get-RecipeCategory is a new command and the old ones still work, so MINOR goes up: 1.0.0 becomes 1.1.0. Use Update-PSModuleManifest -ModuleVersion'
        }

        It '2) the manifest shares Get-RecipeCategory as well as the other three' {
            $data | Should -Not -BeNullOrEmpty -Because 'RecipeBox\RecipeBox.psd1 should be here'
            @($data.FunctionsToExport | Sort-Object) | Should -Be @('Add-Recipe', 'Get-Recipe', 'Get-RecipeCategory', 'Remove-Recipe') -Because 'give Update-PSModuleManifest -FunctionsToExport all four commands: Get-Recipe, Add-Recipe, Remove-Recipe, Get-RecipeCategory'
        }

        It '3) the manifest has release notes that say what is new' {
            $data | Should -Not -BeNullOrEmpty -Because 'RecipeBox\RecipeBox.psd1 should be here'
            "$($data.PrivateData.PSData.ReleaseNotes)" | Should -Match 'Get-RecipeCategory' -Because 'the release notes tell a friend what changed since 1.0.0. Use Update-PSModuleManifest -ReleaseNotes and name the new command'
        }
    }

    Context 'The README' {

        It '4) RecipeBox\README.md starts with the title # RecipeBox' {
            Test-Path -LiteralPath $readme | Should -BeTrue -Because 'the README goes in the RecipeBox folder, beside RecipeBox.psd1, so it travels in the package'
            (Get-Content -Path $readme | Where-Object { $_.Trim() } | Select-Object -First 1).Trim() | Should -Be '# RecipeBox' -Because 'the first line of a README is its title: # RecipeBox'
        }

        It '5) the README says how to install it, with Install-PSResource' {
            Test-Path -LiteralPath $readme | Should -BeTrue -Because 'there is no RecipeBox\README.md yet'
            Get-Content -Path $readme -Raw | Should -Match 'Install-PSResource' -Because 'an Install section shows the command a friend types: Install-PSResource -Name RecipeBox'
        }

        It '6) the README shows an example with one of the commands' {
            Test-Path -LiteralPath $readme | Should -BeTrue -Because 'there is no RecipeBox\README.md yet'
            Get-Content -Path $readme -Raw | Should -Match '(Get-Recipe|Add-Recipe|Remove-Recipe|Get-RecipeCategory)\b' -Because 'an Example section shows a line to copy, such as Get-RecipeCategory'
        }

        It '7) the README names the license' {
            Test-Path -LiteralPath $readme | Should -BeTrue -Because 'there is no RecipeBox\README.md yet'
            Get-Content -Path $readme -Raw | Should -Match '\bMIT\b' -Because 'a License section says which license it is: MIT. See the LICENSE file.'
        }
    }

    Context 'The license' {

        It '8) RecipeBox\LICENSE is the MIT License, word for word' {
            Test-Path -LiteralPath $license -PathType Leaf | Should -BeTrue -Because 'copy licenses\MIT.txt to RecipeBox\LICENSE: a file named LICENSE, with no extension, beside RecipeBox.psd1'
            $text = Get-Content -Path $license -Raw
            $text | Should -Match '^\s*MIT License' -Because 'the file starts with the line MIT License'
            $text | Should -Match 'Permission is hereby granted, free of charge' -Because 'the permission paragraph should be there, unchanged'
            $text | Should -Match 'THE SOFTWARE IS PROVIDED "AS IS"' -Because 'the last paragraph should be there, unchanged'
        }

        It '9) the copyright line has the year and your name' {
            Test-Path -LiteralPath $license -PathType Leaf | Should -BeTrue -Because 'there is no RecipeBox\LICENSE yet'
            $text = Get-Content -Path $license -Raw
            $text | Should -Not -Match '\[year\]|\[fullname\]' -Because 'replace [year] and [fullname] with the year and your name'
            $text | Should -Match 'Copyright \(c\) \d{4} \S' -Because 'the copyright line reads like Copyright (c) 2026 Sam'
        }
    }

    Context 'The package' {

        It '10) practice-repo holds RecipeBox.1.1.0.nupkg' {
            Test-Path -LiteralPath $package | Should -BeTrue -Because 'register practice-repo as PracticeRepo with Register-PSResourceRepository, then Publish-PSResource -Path .\RecipeBox -Repository PracticeRepo. The package is named after the version in the manifest'
        }

        It '11) the package holds the module, its README and its LICENSE' {
            $unpacked | Should -Not -BeNullOrEmpty -Because 'there is no practice-repo\RecipeBox.1.1.0.nupkg yet'
            foreach ($file in 'RecipeBox.psd1', 'RecipeBox.psm1', 'README.md', 'LICENSE') {
                Join-Path $unpacked $file | Should -Exist -Because "$file should be in the package. Publish again after it's in the RecipeBox folder"
            }
        }

        It '12) RecipeBox from the package loads and Get-RecipeCategory works' {
            $unpacked | Should -Not -BeNullOrEmpty -Because 'there is no practice-repo\RecipeBox.1.1.0.nupkg yet'
            $module = Import-Module (Join-Path $unpacked 'RecipeBox.psd1') -Force -PassThru
            $module.Version.ToString() | Should -Be '1.1.0' -Because 'the package should hold version 1.1.0'
            $module.ExportedCommands.Keys | Should -Contain 'Get-RecipeCategory' -Because 'a friend who installs the package should be able to run Get-RecipeCategory'
            $baking = Get-RecipeCategory -Path $testData | Where-Object Category -eq 'Baking'
            $baking.Recipes | Should -Be 2 -Because 'the test recipes have two in Baking'
        }
    }
}

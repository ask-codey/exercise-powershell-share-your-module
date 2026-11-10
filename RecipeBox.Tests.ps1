# Your tests for the RecipeBox module, from Exercise: Test Your Tool, with one more for Get-RecipeCategory.
# Run them from this folder with: Invoke-Pester .\RecipeBox.Tests.ps1

BeforeAll {
    Import-Module "$PSScriptRoot\RecipeBox\RecipeBox.psd1" -Force
}

Describe 'RecipeBox' {
    BeforeEach {
        # A fresh copy of the five test recipes for every test, in Pester's throwaway TestDrive: folder.
        $box = Join-Path $TestDrive 'recipes.json'
        Copy-Item -Path "$PSScriptRoot\test-data\recipes.json" -Destination $box
    }

    It 'Get-Recipe returns every recipe in the box' {
        Get-Recipe -Path $box | Should -HaveCount 5
    }

    It 'Get-Recipe -Category Baking returns only the baking recipes' {
        (Get-Recipe -Category Baking -Path $box).Name | Should -Be 'Apple Crumble', 'Banana Bread'
    }

    It 'Get-Recipe -MaxMinutes 30 includes a recipe that takes exactly 30 minutes' {
        (Get-Recipe -MaxMinutes 30 -Path $box).Name | Should -Contain 'Lemon Garlic Pasta'
    }

    It 'Add-Recipe saves the new recipe, so Get-Recipe finds it afterwards' {
        Add-Recipe -Name 'Trail Mix' -Minutes 5 -Category Snack -Path $box
        Get-Recipe -Name 'Trail Mix' -Path $box | Should -HaveCount 1
    }

    It "Add-Recipe refuses a name that's already in the box" {
        { Add-Recipe -Name 'Tomato Soup' -Minutes 25 -Category Lunch -Path $box } | Should -Throw
    }

    It 'Remove-Recipe -WhatIf leaves the recipe in the box' {
        Remove-Recipe -Name 'Tomato Soup' -Path $box -WhatIf
        Get-Recipe -Name 'Tomato Soup' -Path $box | Should -HaveCount 1
    }

    It 'Get-RecipeCategory counts the recipes in each category' {
        $baking = Get-RecipeCategory -Path $box | Where-Object Category -eq 'Baking'
        $baking.Recipes | Should -Be 2
    }
}

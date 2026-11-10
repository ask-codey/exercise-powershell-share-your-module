# Exercise: Share Your Module

Exercise code for the lesson **Exercise: Share Your Module** in PowerShell in Depth on [ask-codey.com](https://www.ask-codey.com).

`RecipeBox` is the recipe box module from *Exercise: Test Your Tool*, with its manifest and its tests, and one new command since version 1.0.0: `Get-RecipeCategory` counts the recipes in each category. It works, but only on your computer. Your job is to get it ready to share, the way the modules you install are: a version number that says what changed, a README, a license, and a package published to a practice repository, where a friend could install it from.

## What's here

- `RecipeBox\RecipeBox.psm1`: the module, with `Get-RecipeCategory` at the end. Ready to use; don't change it.
- `RecipeBox\RecipeBox.psd1`: the manifest, still at version 1.0.0, still sharing only the first three commands. For you to update.
- `licenses\MIT.txt`: the MIT License, with `[year]` and `[fullname]` for you to fill in.
- `practice-repo\`: an empty practice repository (its `README.txt` keeps the folder in Git). Your package goes here.
- `RecipeBox.Tests.ps1`: the tests from *Exercise: Test Your Tool*, with one more for `Get-RecipeCategory`. It fails until the manifest shares the new command.
- `test-data\recipes.json`: five test recipes, two of them Baking.
- `Check.Tests.ps1`: the check. You don't need to change it.

## What to do

Open PowerShell 7 in this folder (the one with `Check.Tests.ps1` in it).

1. **A new version.** A new command, with the old ones still working, raises MINOR: 1.0.0 becomes 1.1.0. Use `Update-PSModuleManifest` on `RecipeBox\RecipeBox.psd1` with `-ModuleVersion 1.1.0`, `-FunctionsToExport` with all four commands (`Get-Recipe`, `Add-Recipe`, `Remove-Recipe`, `Get-RecipeCategory`), and `-ReleaseNotes` with a sentence that names `Get-RecipeCategory`. Check it with `Test-ModuleManifest`, then run `Invoke-Pester .\RecipeBox.Tests.ps1`: all seven tests should pass now.
2. **A README.** Write `RecipeBox\README.md`, beside the manifest. Start it with the title `# RecipeBox`, then a sentence or two on what it does, an `## Install` section with `Install-PSResource -Name RecipeBox`, an `## Example` section with a line or two that use the module's commands, and a `## License` section that says it's MIT.
3. **A license.** Copy `licenses\MIT.txt` to `RecipeBox\LICENSE` (no extension), and replace `[year] [fullname]` with the year and your name. Leave the rest word for word.
4. **Publish it.** Register `practice-repo` as a repository named `PracticeRepo` with `Register-PSResourceRepository` (use `"$PWD\practice-repo"` for its `-Uri`, and `-Trusted`), publish with `Publish-PSResource -Path .\RecipeBox -Repository PracticeRepo`, and look for it with `Find-PSResource -Name RecipeBox -Repository PracticeRepo`.
5. **Clean up.** `Unregister-PSResourceRepository -Name PracticeRepo`. The registration is saved for your account until you remove it; the folder and the package stay.

## Check your work

The check needs Pester 5 or newer. Install it once, if you haven't already:

```powershell
Install-PSResource Pester
```

Then, from this folder:

```powershell
Invoke-Pester .\Check.Tests.ps1
```

At first all twelve tests fail: that is expected. Each step turns some of them green. A failing test says what it looked for and where, for example *because give Update-PSModuleManifest -FunctionsToExport all four commands*. The last two open your package the way a friend would: they unzip it into a throwaway folder and load RecipeBox from there.

If PowerShell says the check *cannot be loaded* because it *is not digitally signed*, or because *running scripts is disabled*, the folder came from a download that Windows marked as from the internet. Unblock its files once with `Get-ChildItem -Recurse | Unblock-File`, from this folder, and run the check again.

## The rules

- Don't change `RecipeBox.psm1`, `test-data\recipes.json` or `Check.Tests.ps1`.
- The README and the LICENSE go inside the `RecipeBox` folder, so they travel in the package.
- Changed something after you published? Publish again: in a practice folder, the new package replaces the old one with the same version.

## Tips

- `Update-PSModuleManifest` changes only what you give it; `Get-Help Update-PSModuleManifest -Examples` shows more.
- `Copy-Item -Path .\licenses\MIT.txt -Destination .\RecipeBox\LICENSE` makes the license file; then open it in your editor.
- In a README, a line indented by four spaces is shown as code.
- Windows PowerShell 5.1 has no `Update-PSModuleManifest` or `Publish-PSResource`; do this exercise in PowerShell 7.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.

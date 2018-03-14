function Format-VSCodeSplat
{
    <#
    .DESCRIPTION
    Takes the selected function with parameters and creates the needed splat call

    .EXAMPLE
    Copy-Item -Path $path -Destination c:\temp -Force

    $item = @{
        Path = $path
        Destination = 'c:\temp'
        Force = $true
    }
    Copy-Item @item

    #>
    [Cmdletbinding()]
    param
    (
        # VSCode context
        [Microsoft.PowerShell.EditorServices.Extensions.EditorContext]
        $context
    )

    try 
    {
        if ($null -ne $context)
        {
            $text = $context.CurrentFile.GetText($context.SelectedRange) | Out-String
            $output = Format-Splat -InputObject $text
            if ($output)
            {
                $context.CurrentFile.InsertText($output, $context.SelectedRange)
            }
        }
    }
    catch 
    {
        $pseditor.window.ShowWarningMessage($PSitem.ToString())
    }
}

if ($psEditor)
{
    $EditorCommand = @{
        Name           = 'Invoke-VSSplat'
        DisplayName    = 'Refactor: splat parameters for cmdlet'
        Function       = 'Format-VSCodeSplat'
        SuppressOutput = $true
    }
    Register-EditorCommand  @EditorCommand
}









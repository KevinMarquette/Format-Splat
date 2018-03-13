function Format-VSSplat
{
    [Cmdletbinding()]
    param
    (
        [Microsoft.PowerShell.EditorServices.Extensions.EditorContext]
        $context
    )

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

if ($psEditor)
{
    $EditorCommand = @{
        Name           = 'Invoke-VSSplat'
        DisplayName    = 'Refactor: splat parameters for cmdlet'
        Function       = 'Format-VSSplat'
        SuppressOutput = $true
    }
    Register-EditorCommand  @EditorCommand
}
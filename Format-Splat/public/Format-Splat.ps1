function Format-Splat
{
    <#
    .DESCRIPTION
    formats a function call into a splatted call

    .EXAMPLE
    $text = 'Copy-Item -Path $path -Destination c:\temp -Force'

    PS> Format-Splat $text

    $item = @{
        Path = $path
        Destination = 'c:\temp'
        Force = $true
    }
    Copy-Item @item


    #>
    [OutPutType('System.String')]
    [Cmdletbinding()]
    param
    (
        # The text to format into an appropriate splat command
        [parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )]
        [string]
        $InputObject
    )

    $script = [scriptblock]::Create($InputObject)
    $ast = $script.ast

    $command = $ast | Select-AST -Type CommandAst

    $parameters = [ordered]@{}
    $currentParameter = $null
    $function = ''
    $parent = $null
    $other = @()

    $mode = 'function'
    foreach ($token in $command.CommandElements)
    {
        if ($null -ne $parent -and $parent -ne $token.Parent)
        {
            continue
        }

        switch ($mode)
        {
            'function'
            {
                if ($token -is [System.Management.Automation.Language.StringConstantExpressionAst])
                {
                    $function = $token.Value
                    $mode = 'parameter'
                    $parent = $token.Parent
                }
            }
            'value'
            {
                if ($token -is [System.Management.Automation.Language.StringConstantExpressionAst])
                {
                    $parameters[$currentParameter] = "'{0}'" -f $token.Value
                }
                elseif (-not($token -is [System.Management.Automation.Language.CommandParameterAst]))
                {
                    $parameters[$currentParameter] = $token.Extent
                }
                $currentParameter = $null
                $mode = 'parameter'
            }
            'parameter'
            {
                if ($token -is [System.Management.Automation.Language.CommandParameterAst])
                {
                    $currentParameter = $token.ParameterName
                    $parameters[$currentParameter] = '$true'
                    $mode = 'value'
                }
                else
                {
                    $other += $token.Extent
                }
            }
        }
    }

    if ($parameters.count -lt 1)
    {
        return $InputObject
    }

    $output = @()
    $splatName = $function -split '-' | Select-Object -Last 1
    $splatName = $splatName.substring(0, 1).tolower() + $splatName.substring(1)

    $output += '${0} = @{{' -f $splatName
    foreach ($node in $parameters.GetEnumerator())
    {
        $paramName = $node.Name.substring(0, 1).toUpper() + $node.Name.substring(1)
        $output += '    {0} = {1}' -f $paramName, $Node.Value
    }
    $output += '}'
    if ($other.count -gt 0)
    {
        $output += '{0} {1} @{2}' -f $function, ($other -join ' '), $splatName
    }
    else
    {
        $output += '{0} @{1}' -f $function, $splatName
    }

    $output | Out-String -Width 1000
}

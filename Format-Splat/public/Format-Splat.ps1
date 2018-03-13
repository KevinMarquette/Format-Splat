function Format-Splat
{
    [Cmdletbinding()]
    param
    (
        [parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )]
        [string]$InputObject
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
    $output = @()
    $splat = $function -split '-' | select -Last 1

    $output += '${0} = @{{' -f $splat
    foreach ($node in $parameters.GetEnumerator())
    {
        $output += '    {0} = {1}' -f $node.Name, $Node.Value
    }
    $output += '}'
    $output += '{0} {1} @{2}' -f $function, ($other -join ' '), $splat

    $output | Out-String -Width 1000
}

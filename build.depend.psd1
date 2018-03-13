@{ 
    PSDependOptions  = @{ 
        Target    = '$DependencyPath/_build-cache/'
        AddToPath = $true
    }
    InvokeBuild      = '4.1.0'
    PSDeploy         = '0.2.2'
    BuildHelpers     = '1.0.0'
    PSScriptAnalyzer = '1.16.1'
    'Select-Ast'     = '0.1.0'
    Pester           = @{
        Version = '4.1.0'
    }
}
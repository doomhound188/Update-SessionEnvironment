function Update-SessionEnvironment {

  Write-FunctionCallLogMessage -Invocation $MyInvocation -Parameters $PSBoundParameters

  $refreshEnv = $false
  $invocation = $MyInvocation
  if ($invocation.InvocationName -eq 'refreshenv') {
    $refreshEnv = $true
  }

  if ($refreshEnv) {
    Write-Output 'Refreshing environment variables from the registry for powershell.exe. Please wait...'
  } else {
    Write-Verbose 'Refreshing environment variables from the registry.'
  }

  $userName = $env:USERNAME
  $architecture = $env:PROCESSOR_ARCHITECTURE
  $psModulePath = $env:PSModulePath

  $ScopeList = 'Process', 'Machine'
  if ('SYSTEM', "${env:COMPUTERNAME}`$" -notcontains $userName) {
    $ScopeList += 'User'
  }
  foreach ($Scope in $ScopeList) {
    Get-EnvironmentVariableNames -Scope $Scope |
        ForEach-Object {
          Set-Item "Env:$_" -Value (Get-EnvironmentVariable -Scope $Scope -Name $_)
        }
  }

  $paths = 'Machine', 'User' |
    ForEach-Object {
      (Get-EnvironmentVariable -Name 'PATH' -Scope $_) -split ';'
    } |
    Select-Object -Unique
  $Env:PATH = $paths -join ';'

  $env:PSModulePath = $psModulePath

  if ($userName) { $env:USERNAME = $userName; }
  if ($architecture) { $env:PROCESSOR_ARCHITECTURE = $architecture; }

  if ($refreshEnv) {
    Write-Output 'Finished'
  }
}

Set-Alias refreshenv Update-SessionEnvironment

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
param()

function Get-SSHHost($sshConfigPath) {
  $sshConfigPath = $sshConfigPath.Replace('/', '\')
  if ($sshConfigPath -NotMatch ':\\|^(\\|~)') {
    $sshConfigPath = '~\.ssh\' + $sshConfigPath
  }
  Get-Content -Path $sshConfigPath `
  | Select-String -Pattern '^Host ' `
  | ForEach-Object -Process { $_ -replace 'Host ', '' } `
  | ForEach-Object -Process { $_ -split ' ' } `
  | Sort-Object -Unique `
  | Select-String -NotMatch -Pattern '[?!*]'
}

Register-ArgumentCompleter -CommandName 'ssh', 'scp', 'sftp' -Native -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)

  $sshPath = "$env:USERPROFILE\.ssh"

  [Collections.Generic.List[String]]$hosts = Get-Content -Path "$sshPath\config" `
  | Select-String -Pattern '^Include ' `
  | ForEach-Object -Process { $_ -replace 'Include ', '' } `
  | ForEach-Object -Process { Get-SSHHost "$_" }
  $hosts += Get-SSHHost "$sshPath\config"

  $hosts = $hosts | Sort-Object -Unique

  $hosts | Where-Object { $_ -like "$wordToComplete*" } `
  | ForEach-Object -Process { $_ }
}

<#
function Get-SSHKnownHost($sshKnownHostsPath) {
  Get-Content -Path $sshKnownHostsPath `
  | ForEach-Object -Process { $_.Split(' ')[0] } `
  | Sort-Object -Unique
}

Register-ArgumentCompleter -CommandName 'ssh', 'scp', 'sftp' -Native -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)

  $sshPath = "$env:USERPROFILE\.ssh"

  [Collections.Generic.List[String]]$config_hosts = Get-Content -Path "$sshPath\config" `
  | Select-String -Pattern '^Include ' `
  | ForEach-Object -Process { $_ -replace 'Include ', '' } `
  | ForEach-Object -Process { Get-SSHHost "$_" }
  $config_hosts += Get-SSHHost "$sshPath\config"
  $known_hosts = Get-SSHKnownHost "$sshPath\known_hosts"

  $config_hosts = $config_hosts | Sort-Object -Unique
  $known_hosts = $known_hosts | Sort-Object -Unique

  if ($wordToComplete -match '^(?<user>[-\w/\\]+)@(?<host>[-.\w]+)$') {
    $known_hosts | Where-Object { $_ -like "$($Matches['host'].ToString())*" } `
    | ForEach-Object -Process { "$($Matches['user'].ToString())@$_" }
  }
  else {
    $config_hosts | Where-Object { $_ -like "$wordToComplete*" } `
    | ForEach-Object -Process { $_ }
  }
}
#>

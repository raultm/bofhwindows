# Abrir un terminal de Powershell como Administrador
# Set-ExecutionPolicy Unrestricted -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/raultm/bofhwindows/master/menu.ps1'))

function Show-Menu
{
  param(
    [string]$Title="Opciones"
  )
  cls
  Write-Host ""
  Write-Host "     $Title"
  Write-Host ""
  Write-Host "  1) Crear usuario administrador"
  Write-Host "  2) Crear usuario"
  Write-Host "  3) Instalar Chocolatey"
  Write-Host "  4) Cambiar Nombre de la maquina. Actualmente '$env:computername'. Necesita reinicio"
  Write-Host "  5) Habilitar SSH (Cliente Servidor)"
  Write-Host "  6) Habilitar WSL (Windows Subsystem Linux)"
  Write-Host "  7) Deshabilitar Cortana"
  Write-Host "  8) Mostrar Licencia Windows"
}

function Create-User([string]$username, [string]$password, [string]$fullname)
{
  ""
  "  Creando usuario. $username, $password, $fullname"
  if(!$password){
	  $password='/passwordreq:no'
  }else{
	  $password="'$password'"
  }
  
  if(!$fullname){
	  $fullname = $username
  }
  
  $cmd = "(NET USER /add $username $password /fullname:'$fullname')"
  "$cmd"
  iex $cmd
  #(NET USER /add $username  '$password' /fullname:'$fullname')
  #New-LocalUser "$username" -Password $password -FullName "$fullname"
  "  Creado. $username : $fullname"
}

function Set-Admin-Role([string]$username)
{
  ""
  "  Asignado rol de administrador a $username"
  $cmd = "NET LOCALGROUP 'Administradores' '$username' /add"
  "$cmd"
  iex $cmd
  "  Rol asignado"
}

function Install-Chocolatey
{
  "  Chocolatey"
  '    Instalando Chocolatey...'
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  '    Instalacion Chocolatey finalizada'
}

function Enable-SSH
{
  ""
  "  Instalando cliente SSH"
	Add-WindowsCapability -Online -Name OpenSSH.Client*  
	"  Instalando servidor SSH"
	Add-WindowsCapability -Online -Name OpenSSH.Server*
	"  Instalados Cliente y Servidor OpenSSH"
}

function Enable-WSL
{
  "  Habilitando WSL"
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
  "  WSL Habilitado"
}

function Disable-Cortana
{
  "  Deshabilitando Cortana"
  New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Windows Search' | Out-Null
  New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -PropertyType DWORD -Value '0' | Out-Null 
  "  Cortana Deshabilitada"
}

do
{
  Show-Menu
  ""
  $input=Read-Host "Selecciona opcion"
  switch($input)
  {
    '1'{
      $username=Read-Host "Nombre del usuario (en minusculas, sin espacios ni caracteres raros mejor)"
      $password=Read-Host  "Password (vacío para usuario sin contraseña)"
      $fullname=Read-Host  "Nombre Visible (vacío si quieres que sea el mismo nombre de usuario)"
      Create-User $username $password $fullname
      Set-Admin-Role $username
    }'2'{
      $username=Read-Host "Nombre del usuario (en minusculas, sin espacios ni caracteres raros mejor)"
      $password=Read-Host  "Password (vacío para usuario sin contraseña)"
      $fullname=Read-Host  "Nombre Visible (vacío si quieres que sea el mismo nombre de usuario)"
      Create-User $username $password $fullname""
      
    }'3'{
      Install-Chocolatey
    }'4'{
      $newName=Read-Host "Escribe nuevo nombre"
	    Rename-Computer -ComputerName $env:computername -NewName $newName
    }'5'{
      Enable-SSH
    }'6'{
	    Enable-WSL
    }'7'{
	    Disable-Cortana
    }'8'{
	    (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey 
    }'q'{
      return
    }
  }
  pause
}
until($input -eq 'q')

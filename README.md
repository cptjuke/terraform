#terraform

Test repository for a deployment of a ubuntu 20.04 virtual machine in azure

For the debloyment to be successful we have to be previously logged in azure
az login in powershell

Its important to associate the virtual network with the virtual interface and create the rules for the 22 port
Public IP has to be set on static, azure will assign one by default

Generate the ssh keys and specify them in the configuration file alongside the allowed user.

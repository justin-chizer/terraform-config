If present continue else create the core
Draw up diagram and give lables


A folder for acrchitecture 
	high level design
	Design.md put Assumptions here, Requirements. Blockers. Brain dump
		Assumptions shows don't talk to each other
		Requirements show in Europe and then move to LA. Active /Active Resiliency? HA? DR? GRS Storage of their data?
		
src folder
	tf
		core, nework, show infra


## Assumptions 

- For now, Greenfield
- Currently ignoring imaging the VM
- 

## Requirements

- Hub and Spoke networking
- Shows do not talk to each other
- On prem network connects to the hub via point to site VPN. (Point being my laptop as "On Prem")
- Be able to move show from one region to another
- Active/Active?
- HA?
- DR? GRS storage gives us 16 9s
- Hub = VNet, Core inside a subnet, AAD, DNS, KeyVault inside a different subnet
- Each spoke is a show
- Shows are in their own VNet and are peered to the Hub
- Shows will consist of multiple VMs and a Storage account with proper networking constraints
- CI/CD pipeline in either Pipelines or GitHub Actions
- Include checkov.io
- Alternative to Terratest
- Using TF 0.12.25. azurerm = 2.10.0




## Blockers

- How to maintain multiple state files?
- Will we extend existing infrastructure or manage it?

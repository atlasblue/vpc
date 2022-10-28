<h1>Terraform Example to Deploy Nutanix VPC constructs </h1>

- Enable Flow Virtual Networking in Prism Central (PC) <br/>
- Create new subnet for External Connectivity for VPCs with NAT
<img width="637" alt="Screen Shot 2022-10-21 at 23 01 32" src="https://user-images.githubusercontent.com/92083755/197288339-796d07a6-1cc5-4803-8098-4bd5b081a81d.png"> <br/>
- Add Nutanix provider in Terraform <br/>
- Using terraform.tfvars to specify Nutanix Prism Central connection parameters and VLAN name :<br/>
    * Prism Central endpoint/IP address <br/>
    * Prism Central username <br/>
    * Prism Central password <br/>
    * EXTERNAL Subnet Name <br/>
- terraform init <br />
- terraform plan <br />
- terraform apply -auto-approve <br />
- terraform destroy # optional, when finished

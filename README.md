Terraform Examples to Deploy Nutanix VPC constructs 

- Enable Flow Virtual Networking in Prism Central (PC) <br />
- Create new subnet for External Connectivity for VPCs with NAT
<img width="637" alt="Screen Shot 2022-10-21 at 23 01 32" src="https://user-images.githubusercontent.com/92083755/197288339-796d07a6-1cc5-4803-8098-4bd5b081a81d.png">
- Edit terraform.tfvars to match your environment (PC username / PC password / PC ENDPOINT (IP@) / EXTERNAL VLAN)<br />
- terraform init <br />
- terraform plan <br />
- terraform apply -auto-approve <br />

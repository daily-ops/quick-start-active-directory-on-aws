## Terraform configuration for Windows Server 2022 + Active Directory Installation on AWS
A quick start using Terraform configuration to create Windows Server 2022 with Active Directory feature added on AWS

### Pre-requisites

* Terraform binary - If you currently don't have Terraform installed on your machine, this [guide](https://developer.hashicorp.com/terraform/install) will show you how to install the executable.
* AWS account - AWS credential is required for AWS provider. Without modification to any part of the configuration, you may choose to use AWS profile or Environment Variable method, listed in this [guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration), otherwise the provider configuratoin can be modified to suit the need with any supported method.
* Key Pair - You may follow this [guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws) to create and import key pair into AWS.

### What does the repository do?

- Create VPC
- Create a Subnet
- Create a Security Group allowing RDP port **3389** from **ANYWHERE**.
- Create an Intenet Gateway
- Create a Windows Server 2022 instance with the default `t2.micro` free tier.

### Quick steps

* Setup AWS credential as mentioned in the pre-requisites.
* Clone the repository and cd into it.

    ```
    git clone https://github.com/daily-ops/quick-start-active-directory-on-aws.git && cd quick-start-active-directory-on-aws
    ```

* Create file `terraform.tfvars` in the root directory with the following variables.

   
    |Variable|Value|
    |-|-|
    |aws_region|AWS region of the VPC and Windows Server to be created|
    |dns_domain|DNS name to be configured in Windows Server|
    |recovery_password|Recovery password for Windows Server|
    |domain_netbios_name|Domain NETBIOS name|
    |key_name|Name of the key-pair in AWS can be used to retrieved Administrator password post-provisioning|
    |instance_type|Optionally, you can override the Instance type which is defaulted to `t2.micro`|

    For example,

    ```
    aws_region = "ap-southeast-2"
    dns_domain = "yourlabs.com"
    recovery_password = "Passw0rd!"
    domain_netbios_name = "YOURLABS"
    key_name = "windows-server"
    ```

* Initialise working directory, plan, and apply.

    ```
    terraform init
    terraform plan
    terraform apply
    ```

* The output contains the public ip of the Windows Server to establish RDP from wherever you want. You may retrieve password of the `Administrator` user via [AWS console](https://repost.aws/knowledge-center/retrieve-windows-admin-password) or [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/ec2/get-password-data.html)

    ```
    terraform output
    vpc-name = "department-hmbx"
    win-server-public-ip = "13.210.168.194"
    ```

### DO NOT FORGET TO DESTROY THE RESOURCES

```
terraform destroy -auto-approve
```



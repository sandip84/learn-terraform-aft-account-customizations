# Learn Terraform - Use Control Tower Account Factory for Terraform

This is a companion repository for the Hashicorp [Provision and Manage Accounts with
Control Tower Account Factory for Terraform
tutorial](https://developer.hashicorp.com/terraform/tutorials/aws/aws-control-tower-aft).

This repository contains boilerplate configuration for defining account
customizations to use with the Account Factory for Terraform
module. The README below and the template files in this repository were
provided by AWS.

To create your account customizations, replicate this repository
and extend the Terraform configuration.

## Introduction
This repo stores the Terraform and API helpers for the Account Customizations.
Account Customizations are used to customize all provisioned accounts with
customer defined resources. The resources can be created through Terraform or
through Python, leveraging the API helpers. The customization run is
parameterized at runtime.

## Usage
To create an account specific baseline, copy the ACCOUNT_TEMPLATE folder into a
new folder. The new folder name should be the account ID you wish to baseline.

## Usage
To leverage Account Customizations, start by copying the ACCOUNT_TEMPLATE
folder into a new folder. The new folder name should match the
```account_customizations_name``` provided in the account request for the
accounts you would like to baseline. Then, populate the target folder as per
the instructions below.

## Included sandbox example

The `sandbox-customization` folder matches this account request setting:

```hcl
account_customizations_name = "sandbox-customization"
```

It demonstrates an opt-in sandbox baseline that:

* Reads `custom_fields.group` from
  `/aft/account-request/custom-fields/group` in the target account.
* Blocks public S3 access at the account level.
* Creates a private, encrypted, versioned artifact bucket.
* Removes non-current object versions after 30 days to limit sandbox cost.

Use the global customizations repository for controls and resources required in
every AFT-managed account. Use this repository when an account or a group of
accounts needs a selectable configuration such as `sandbox-customization`,
`production-customization`, or `data-platform-customization`.

### Terraform

AFT provides Jinja templates for Terraform backend and providers. These render
at the time Terraform is applied. If needed, additional providers can be
defined by creating a providers.tf file.

To create Terraform resources, provide your own Terraform files (ex. main.tf,
variables.tf, etc) with the resources you would like to create, placing them in
the 'terraform' directory.

### API Helpers

The purpose of API helpers is to perform actions that cannot be performed
within Terraform.

#### Python

The api_helpers/python folder contains a requirements.txt, where you can
specify libraries/packages to be installed via PIP.

#### Bash

This is where you define what runs before/after Terraform, as well as the order
the Python scripts execute, along with any command line parameters. These bash
scripts can be extended to perform other actions, such as leveraging the AWS
CLI or performing additional/custom Bash scripting.

- pre-api-helpers.sh - Actions to execute prior to running Terraform.
- post-api-helpers.sh - Actions to execute after running Terraform.

#### Sample api-helpers.sh

Sample #1 - Using AWS CLI to query for resources, save to a variable, and then
pass to a script. In the example below, all running instances are queried,
stopped, and started using AWS CLI and custom Python scritpts.

```
instances=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running")
python ./python/source/stop_instances.py --instances $instances
sleep 10s
python ./python/source/start_instances.py --instances $instances
```

Sample #2 - Query a 3rd party IPAM solution, and save the given CIDR to AWS
Parameter Store. This SSM parameter could be leveraged from Terraform using a
data object to create a VPC.

```
account = $(aws sts get-caller-identity --query Account --output text)
region = $(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].[RegionName]' --output text)
cidr = $(python ./python/source/get_cidr_range.py)
aws ssm put-parameter --name /$account/$region/vpc/cidr --value $cidr
```

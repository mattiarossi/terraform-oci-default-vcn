### Create VCN
This example creates one VCN in Oracle Cloud Infrastructure including default route table, DHCP options and subnets, and stores the resulting terraform state file in an OCI Object Storage Bucket
It is supposed to be run from the OCI cloud console, and it does not require any authentication setting, it will use the credentials of the OCI user running the terraform script


### Using this example


# OCI

Create an appropriate Object storage bucket in the compartment that is designed to be the [AWS S3 compatibility layer default](https://docs.cloud.oracle.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm#Viewing).

By default this is the root OCI compartment. You can use the following command to retrieve the setting for your tenancy:

```
oci os ns  get-metadata --output=table
+-------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------+-----------+
| default-s3-compartment-id                                                           | default-swift-compartment-id                                                        | namespace |
+-------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------+-----------+
| ocid1.compartment.oc1..aaaaaaa...4nxhlvbbbbbbb3kpmffof6vba                          | ocid1.compartment.oc1..aaaaaaa...hlvbbbbbbbbpmffof6vba                              | mytenancy |
+-------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------+-----------+
```

This command will create a bucket named tf-fk-test-02 in the AWS s3 compatibility layer compartment:

```
oci os bucket create --compartment-id ocid1.compartment.oc1..aaaaaaa...4nxhlvb3luoh3kpmffof6vba --name tf-fk-test-02
```


# Terraform
Prepare one variable file named "terraform.tfvars" with the required information. The content of "terraform.tfvars" should look something like the following:

```
$ cat terraform.tfvars
# Region
region = "us-phoenix-1"

# Compartment
compartment_ocid = "<Compartment OCID where the VCN will be deployed>"

# VCN Configurations
vcn_display_name = "testVCN"
vcn_cidr = "10.0.0.0/16"
```

If you want to deploy the test VCN in a specific compartment, use the following script to retrieve its id:

```
export COMPARTMENT=my-compartment
oci iam compartment list --query "data[?\"name\"=='$COMPARTMENT']".{"name:\"name\",id:\"id\""} --output=table
+-------------------------------------------------------------------------------------+-----------------------+
| id                                                                                  | name                  |
+-------------------------------------------------------------------------------------+-----------------------+
| ocid1.compartment.oc1..aaaaaaaabmc54lgslm..........................3hygseg6qeh5pvwq | my-compartment        |
+-------------------------------------------------------------------------------------+-----------------------+
```


Edit the file vcn_default.tf, and update the terraform backend section to match your OCI setup:

```
terraform {
  backend "s3" {
    endpoint                    = "https://<mytenancy>.compat.objectstorage.<region>.oraclecloud.com"
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    skip_credentials_validation = true
    bucket                      = "<mybucket>"
    key                         = "terraform/state/oci/vcn/testVCN/terraform.tfstate"
    region                      = "us-phoenix-1"
  }
}

```

where:
* <mytenancy> is your tenancy name
* <region> is the region where you created the Object Storage bucket
* <mybucket> is the name of the bucket you created
* key is the name of the bucket entry that will hold your terraform state file


Then apply the example using the following commands:

```
$ terraform init
$ terraform plan
$ terraform apply
```

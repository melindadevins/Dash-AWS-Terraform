service_name=dashproxy
ec2_instance_type=t2.small
num_nodes=1
cis_ami_id=ami-1853ac65
ec2_keypair_name=mel-ds-dev-east
environment=test
environment_type=dev
primary_region=us-east-1
server_port=8050

config_bucket_name=em-dashproxy-config-test
s3object_key=dash_resources.zip
resource_dir=dash_resources
app_path=/opt/dashproxy
server_port=8050

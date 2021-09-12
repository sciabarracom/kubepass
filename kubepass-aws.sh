#!/bin/bash

P=${P:=kube}
N=${N:=2}
D=${D:=10}

REG=${REG:=eu-central-1}
# ubuntu 20 in eu-central-1
AMI=${AMI:=ami-05f7491af5eef733a}
INST=${INST:=t2.small}

if ! which aws
then echo "Please install and configure aws cli v2 (see https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)"
     exit 1
fi

if ! test -e $HOME/.ssh/id_rsa.pub
then echo "Please generate a key with ssh-key-gen"
     exit 1
fi

echo "Instance Count  : N=$N"
echo "Instance Prefix : P=$P"
echo "CPU/instance    : C=$C"
echo "Memory/instance : M=$M"g
echo "Disk/instance   : D=$D"g

export PAGER=

VPC="$(
        aws ec2 describe-vpcs --filters Name=tag-value,Values=$P-vpc --query 'Vpcs[0].VpcId' --output=text
    )"
SUB="$(
        aws ec2 describe-subnets --filters Name=tag-value,Values=$P-subnet --query 'Subnets[0].SubnetId' --output=text
    )"
IGW="$(
        aws ec2 describe-internet-gateways --filters Name=tag-value,Values=$P-igw --query 'InternetGateways[0].InternetGatewayId' --output=text
    )"
RTB="$(
        aws ec2 describe-route-tables --filters Name=tag-value,Values=$P-rtb --query 'RouteTables[0].RouteTableId' --output=text
    )"
SG="$(
        aws ec2 describe-security-groups --filters Name=tag-value,Values=$P-sg --query 'SecurityGroups[0].GroupId' --output=text
    )"

INSTANCES="$(
        aws ec2 describe-instances  --query 'Reservations[*].Instances[*].InstanceId' --filters Name=tag:Cluster,Values=${P} --output=text 
)"

if [[ "$1" == "destroy" ]]
then
    echo "Destroying $P"
    aws ec2 delete-route-table --route-table-id $RTB
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW
    aws ec2 delete-subnet --subnet-id $SUB
    aws ec2 delete-vpc --vpc-id $VPC
    aws ec2 delete-security-group --group-id $SG
    aws ec2 delete-key-pair --key-name $P-key
    echo $INSTANCES | xargs -n 1 aws ec2 terminate-instances --instance-ids
    exit 1
fi

if [[ $VPC == "None" ]] ; then 
VPC="$(
    aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$P-vpc}]" --query Vpc.VpcId --output text
    )"
    echo "Created VPC: $VPC"
fi

if [[ $SUB == "None" ]] ; then 
SUB="$(
    aws ec2 create-subnet --vpc-id $VPC --cidr-block 10.0.0.0/24 --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$P-subnet}]" --query Subnet.SubnetId --output text
    )"
    echo "Created SUB: $SUB"
fi

if [[ $IGW == "None" ]] ; then
IGW="$(
    aws ec2 create-internet-gateway  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$P-igw}]" --query InternetGateway.InternetGatewayId --output text
    )"
    echo "Created IGW: $IGW"
fi

if [[ $RTB == "None" ]] ; then 
RTB="$(
    aws ec2 create-route-table --vpc-id $VPC --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$P-rtb}]" --query RouteTable.RouteTableId --output text
    )"
    echo "Created RTB: $RTB"
    aws ec2 create-route --route-table-id $RTB --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW
    aws ec2 associate-route-table  --subnet-id $SUB --route-table-id $RTB
fi

if [[ $SG == "None" ]] ; then
SG="$(
    aws ec2 create-security-group --group-name $P-sg --description $P-sg --vpc-id $VPC --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=$P-sg}]" --query GroupId --output text
    )"
    echo "Created SG: $SG"
    aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 22 --cidr 0.0.0.0/0
fi

echo "VPC: $VPC"
echo "SUB: $SUB"
echo "IGW: $IGW"
echo "RTB: $RTB"
echo "SG: $SG"

aws ec2 attach-internet-gateway --vpc-id $VPC --internet-gateway-id $IGW

aws ec2 import-key-pair --key-name "$P-key" --public-key-material fileb://$HOME/.ssh/id_rsa.pub

I=0
for ((I=0 ; I < $N ; I++))
do
  IP=$((10 + $I))
  PRIV="10.0.0.$IP"
  PUB=""
  [[ $I == 0 ]] && PUB="--associate-public-ip-address"
  aws ec2 run-instances \
    --count 1 \
    --image-id $AMI \
    --instance-type $INST \
    --key-name "$P-key" \
    --security-group-ids $SG \
    --subnet-id $SUB \
    --private-ip-address $PRIV $PUB\
    --query 'Instances[0].InstanceId' \
    --output text \
    --user-data file://$PWD/kubepass-aws.yaml \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$P$I},{Key=Cluster,Value=$P}]"
done

#multipass transfer "${P}0:/etc/kubeconfig" "kubeconfig"
#kubectl --kubeconfig=kubeconfig get nodes
#echo "Your cluster is ready, configuration saved as ./#kubeconfig"
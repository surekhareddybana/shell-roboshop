#!/bin/bash

# -------------------------------
# Configuration
# -------------------------------

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0900091d833290dd7"
ALL_INSTANCES=("mongodb" "redis" "mysql" "rabitmq" "catalogue" "shipping" "cart" "user" "payment" "dispatch" "frontend")
ZONE_ID="Z10186462WRSH5GYHYLSN" #(in route53 we have zone id)
DOMAIN_NAME="banasurekha.shop"

# -------------------------------
# Parse arguments
# -------------------------------
ACTION=$1
shift

if [ -z "$ACTION" ]; then
  echo "Usage: $0 {create|delete}]"
  exit 1
fi                                 

# Determine which instances to work on
if [ $# -eq 0 ] || [[ "$1" == "all" ]]; then
  SELECTED_INSTANCES=("${ALL_INSTANCES[@]}")
else
  SELECTED_INSTANCES=("$@")
fi

# -------------------------------
# CREATE INSTANCES
# -------------------------------
if [ "$ACTION" == "create" ]; then
  for instance in "${SELECTED_INSTANCES[@]}"; do
    echo "Creating EC2 instance for: $instance ..."

    INSTANCE_ID=$(aws ec2 run-instances \
      --image-id "$AMI_ID" \
      --count 1 \
      --instance-type t3.micro \
      --security-group-ids "$SG_ID" \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
      --query 'Instances[0].InstanceId' \
      --output text)

    echo "$instance instance created with ID: $INSTANCE_ID"

    # Get IP address
    if [ "$instance" == "frontend" ]; then
      IP=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
    else
      IP=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text)
    fi

    echo "$instance IP address: $IP"

    # Create DNS record
    aws route53 change-resource-record-sets \
      --hosted-zone-id $ZONE_ID \
      --change-batch '{
        "Comment": "Add record for '$instance'",
        "Changes": [{
          "Action": "UPSERT",
          "ResourceRecordSet": {
            "Name": "'$instance'.'$DOMAIN_NAME'",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [{"Value": "'$IP'"}]
          }
        }]
      }' >/dev/null

    echo "DNS record created: $instance.$DOMAIN_NAME → $IP"
    echo "
===========================================================
    "
  done
fi

# DELETE INSTANCES
if [ "$ACTION" == "delete" ]; then
  for instance in "${SELECTED_INSTANCES[@]}"; do
    echo "Terminating EC2 instance: $instance ..."

    # Get instance IDs as space-separated string
    INSTANCE_IDS=$(aws ec2 describe-instances \
      --filters "Name=tag:Name,Values=$instance" \
      --query 'Reservations[].Instances[].InstanceId' \
      --output text)

    if [ -n "$INSTANCE_IDS" ]; then
      aws ec2 terminate-instances --instance-ids $INSTANCE_IDS >/dev/null
      echo "Terminated instance: $instance ($INSTANCE_IDS)"
    else
      echo "No instance found with name: $instance"
    fi
    echo "
=============================================================================
"
  done
fi

# AMI_ID="ami-09c813fb71547fc4f"
# SG_ID="sg-0900091d833290dd7"
# INSTANCES=("mongodb" "redis" "mysql" "rabitmq" "catalogue" "shipping" "cart" "user" "payment" "dispatch" "frontend")
# ZONE_ID="Z10186462WRSH5GYHYLSN" #(in route53 we have zone id)
# DOMAIN_NAME="banasurekha.shop"

# #for instance in ${INSTANCES[@]}
# for instance in $@
# do

#    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro  --security-group-ids sg-0900091d833290dd7 --tag-specifations "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceId" --output text)
#    if [ $instance != "frontend" ]
#    then
 
#       IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress"  --output text)
#  RECORD_NAME="$instance.$DOMAIN_NAME"
 
#  else
#       IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress"  --output text)
# RECORD_NAME=$DOMAIN_NAME

# fi
# echo "$instance IP address: $IP"
#  aws route53 change-resource-record-sets \
#  --hosted-zone-id  $ZONE_ID 
#  --change-batch 
#  {
#      "Comment": "CREATE/DELETE/UPDATE".
#        "Changes":[{
#        "Action": "UPSERT",
#        "ResourceRecordSet": {
#           "Name": "'$RECORD_NAME'",
#           "Type": "A",
#           "TTL": 1,
#           "ResourceRecords": [{
#             "Value": "'$IP'"
#             }]
            
                           
#  }

# done
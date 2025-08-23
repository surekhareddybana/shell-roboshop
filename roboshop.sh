#!\bin\bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0900091d833290dd7"
INSTANCES=("mongodb" "redis" "mysql" "rabitmq" "catalogue" "shipping" "cart" "user" "payment" "dispatch" "frontend")
ZONE_ID="Z10186462WRSH5GYHYLSN" #(in route53 we have zone id)
DOMAIN_NAME="banasurekha.shop"

for instance in ${INSTANCES[@]}
do

   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro  --security-group-ids sg-0900091d833290dd7 --tag-specifations "ResourceType=instance,Tags=[{key=Name, value=$instance}]" --query "Instances[0].InstanceId" --output text)
   if [ $instance != "frontend" ]
   then
      IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress"  --output text)
else
      IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress"  --output text)
fi
echo "$instance IP address: $IP"
 aws route53 change-resource-record-sets \
 --hosted-zone-id  $ZONE_ID \
 --change-batch '
 {
     "Comment": "CREATE/DELETE/UPDATE"
       "changes":[{
       "Action": "UPSERT",
       "ResourceRecordSet": {
          "Name": "'$instance'.'$DOMAIN_NAME'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [{
            "Value": "'$IP'"
            }]
            }]
                           
 }

done
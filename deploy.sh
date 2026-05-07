
# VARIABLES PRINCIPALES

REGION="us-east-1"
AMI_ID="ami-0c02fb55956c7d316"   # Amazon Linux 2
KEY_NAME="nueva-key"                # Key Pair creada previamente
MY_IP="$(curl -s ifconfig.me)/32"


# CREACION DE VPC

echo "Creando VPC..."

export VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

echo "VPC creada: $VPC_ID"

# Activar DNS en la VPC
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-support "{\"Value\":true}"

aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames "{\"Value\":true}"


# CREACION DE SUBREDES


echo "Creando subred publica..."

export SUBNET_PUBLIC_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ${REGION}a \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Subred publica: $SUBNET_PUBLIC_ID"

echo "Creando subred privada..."

export SUBNET_PRIVATE_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ${REGION}b \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Subred privada: $SUBNET_PRIVATE_ID"

# Permitir IP publica automatica
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_PUBLIC_ID \
  --map-public-ip-on-launch


# INTERNET GATEWAY


echo "Creando Internet Gateway..."

export IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID


# TABLA DE RUTEO


echo "Configurando tabla de rutas..."

export RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' \
  --output text)

# Ruta hacia internet
aws ec2 create-route \
  --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

# Asociar tabla a subred publica
aws ec2 associate-route-table \
  --subnet-id $SUBNET_PUBLIC_ID \
  --route-table-id $RT_ID


# SECURITY GROUP


echo "Creando Security Group..."

export SG_ID=$(aws ec2 create-security-group \
  --group-name web-sg \
  --description "Permitir HTTP y SSH" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

# Puerto HTTP
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Puerto SSH solo para mi IP
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr $MY_IP


# CREACION DE EC2

echo "Lanzando instancia EC2..."

export INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --key-name $KEY_NAME \
  --subnet-id $SUBNET_PUBLIC_ID \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instancia creada: $INSTANCE_ID"

# Esperar a que la instancia este running
aws ec2 wait instance-running \
  --instance-ids $INSTANCE_ID

# Obtener IP publica
export PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "IP Publica: $PUBLIC_IP"


# CREACION DE VOLUMEN EBS

echo "Creando volumen EBS..."

export AZ=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' \
  --output text)

export VOLUME_ID=$(aws ec2 create-volume \
  --size 8 \
  --availability-zone $AZ \
  --volume-type gp3 \
  --query 'VolumeId' \
  --output text)

# Esperar que el volumen este disponible
aws ec2 wait volume-available \
  --volume-ids $VOLUME_ID

# Adjuntar volumen a EC2
aws ec2 attach-volume \
  --volume-id $VOLUME_ID \
  --instance-id $INSTANCE_ID \
  --device /dev/sdf

echo "Volumen adjuntado correctamente"

# FINAL
echo "Infraestructura creada correctamente"
echo "Accede desde: http://$PUBLIC_IP"
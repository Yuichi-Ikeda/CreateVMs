#!/bin/bash

# 実行環境に合わせて変更
subscriptionID="xx0000x0-xx00-0000-0x00-0x0x0xxxxx0x"
az account set --subscription $subscriptionID

resourcegroup="ClientVMs-rg"
location="japaneast"
az group create --name $resourcegroup --location $location

# NSG の作成
az network nsg create -g $resourcegroup -n SubnetNSG --location $location
az network nsg rule create -g $resourcegroup --nsg-name SubnetNSG -n AllowRDP --priority 4096 \
    --source-address-prefixes * --source-port-ranges * \
    --destination-address-prefixes 10.0.0.0/24  --destination-port-ranges 3389 --access Allow \
    --protocol Tcp

# VNET の作成と Subnet への NSG 適用
az network vnet create -g $resourcegroup -n VNET --address-prefix 10.0.0.0/16 \
    --subnet-name VMSubnet --subnet-prefix 10.0.0.0/24 \
    --network-security-group SubnetNSG \
    --location $location

# VNET に複数 VM (Windows 10) を作成. 
max=6
for ((i=1; i <= $max; i++)); do
  vmname=`(printf "wndows10-%02d" "${i}")`
  az vm create \
    --resource-group $resourcegroup \
    --location $location \
    --name $vmname \
    --public-ip-address-dns-name $vmname \
    --size Standard_D4s_v4 \
    --vnet-name VNET  \
    --subnet VMSubnet \
    --nsg ""  \
    --image MicrosoftWindowsDesktop:Windows-10:20h1-pro:19041.630.2011061636 \
    --admin-username azureuser \
    --admin-password Demop@ss100! \
    --no-wait
done
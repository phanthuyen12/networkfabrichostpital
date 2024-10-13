#!/bin/bash

peer lifecycle chaincode package organization.tar.gz --path ../chaincode/OrgChaincode --lang node --label organization_1
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="${ORG_VALUE}"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:${PORT_VALUE}

# Lấy package ID của chaincode đã cài đặt
CC_PACKAGE_ID_ORG=$(peer lifecycle chaincode queryinstalled | grep -oP '(?<=Package ID: ).*' | head -n 1 | cut -d ',' -f 1)
echo "Package ID: $CC_PACKAGE_ID_ORG"

# Hiển thị giá trị của PACKAGE_ID

peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
  --channelID channel1 \
  --name organization \
  --version 1.0.1 \
  --package-id $CC_PACKAGE_ID_ORG \
  --sequence 1


peer lifecycle chaincode checkcommitreadiness \
  --channelID channel1 \
  --name organization \
  --version 1.0.1 \
  --sequence 1 \
  --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"




peer lifecycle chaincode package medical.tar.gz --path ../chaincode/OrgChaincode --lang node --label medical_1
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="${ORG_VALUE}"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:${PORT_VALUE}

# Lấy package ID của chaincode đã cài đặt
CC_PACKAGE_ID_MEDICAL=$(peer lifecycle chaincode queryinstalled | grep -oP '(?<=Package ID: ).*' | head -n 1 | cut -d ',' -f 1)
echo "Package ID: $CC_PACKAGE_ID_MEDICAL"

# Hiển thị giá trị của PACKAGE_ID

peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
  --channelID channel1 \
  --name medical \
  --version 1.0.1 \
  --package-id $CC_PACKAGE_ID_MEDICAL \
  --sequence 1


peer lifecycle chaincode checkcommitreadiness \
  --channelID channel1 \
  --name medical \
  --version 1.0.1 \
  --sequence 1 \
  --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

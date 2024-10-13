#!/bin/bash

# Bước 1: Tạo biến môi trường
export PATH=$PATH:$(realpath ../bin)
export FABRIC_CFG_PATH=$(realpath ../config)

# Bước 2: Tạo mạng và kênh
echo "Tạo mạng và kênh..."
./network.sh up createChannel -c channel1 -ca

# Bước 3: Thêm tổ chức mới
echo "Tạo chứng chỉ và tài liệu cấu hình cho tổ chức mới..."
cd ../organizations/peerOrganizations

# Tạo tài liệu chứng chỉ cho tổ chức mới
../../bin/cryptogen generate --config=org-crypto.yaml --output="../organizations"
export FABRIC_CFG_PATH=$PWD
../../bin/configtxgen -printOrg thuyennhiMSP > ../organizations/peerOrganizations/thuyennhi.example.com/thuyennhi.json

# Đưa các thành phần lên Docker
export DOCKER_SOCK=/var/run/docker.sock
cd ../../../
docker-compose -f compose/compose-org.yaml -f compose/docker/docker-compose-org.yaml up -d

# Tìm nạp cấu hình kênh
echo "Tìm nạp cấu hình kênh..."
cd channel-artifacts
peer channel fetch config config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

# Chuyển đổi cấu hình thành JSON
echo "Chuyển đổi cấu hình thành JSON..."
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq ".data.data[0].payload.data.config" config_block.json > config.json

# Thêm tài liệu vào cấu hình
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"thuyennhiMSP":.[1]}}}}}' config.json ../organizations/peerOrganizations/thuyennhi.example.com/thuyennhi.json > modified_config.json
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_config.pb --output thuyennhi_update.pb
configtxlator proto_decode --input thuyennhi_update.pb --type common.ConfigUpdate --output thuyennhi_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'channel1'", "type":2}},"data":{"config_update":'$(cat thuyennhi_update.json)'}}}' | jq . > thuyennhi_update_in_envelope.json
configtxlator proto_encode --input thuyennhi_update_in_envelope.json --type common.Envelope --output thuyennhi_update_in_envelope.pb

# Bước 4: Ký gửi và cập nhật cấu hình
echo "Ký gửi và cập nhật cấu hình..."
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
peer channel signconfigtx -f channel-artifacts/thuyennhi_update_in_envelope.pb

export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer channel update -f channel-artifacts/thuyennhi_update_in_envelope.pb -c channel1 -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

# Fetch block for new org
export CORE_PEER_LOCALMSPID=thuyennhiMSP
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/thuyennhi.example.com/peers/peer0.thuyennhi.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/thuyennhi.example.com/users/Admin@thuyennhi.example.com/msp
export CORE_PEER_ADDRESS=localhost:11053
peer channel fetch 0 channel-artifacts/channel1.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

# Bước 5: Cài đặt chaincode
echo "Cài đặt chaincode..."
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=thuyennhiMSP
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/thuyennhi.example.com/peers/peer0.thuyennhi.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/thuyennhi.example.com/users/Admin@thuyennhi.example.com/msp
export CORE_PEER_ADDRESS=localhost:11053

# Đóng gói và cài đặt chaincode
peer lifecycle chaincode package hospital.tar.gz --path ../chaincode --lang node --label hospital_1.0.1
peer lifecycle chaincode install hospital.tar.gz

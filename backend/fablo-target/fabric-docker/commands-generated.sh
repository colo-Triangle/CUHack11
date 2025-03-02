#!/usr/bin/env bash

generateArtifacts() {
  printHeadline "Generating basic configs" "U1F913"

  printItalics "Generating crypto material for Org1" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-org1.yaml" "peerOrganizations/org1.healthcare.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for Doctor" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-doctor.yaml" "peerOrganizations/doctor.healthcare.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for Patient" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-patient.yaml" "peerOrganizations/patient.healthcare.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating genesis block for group group1" "U1F3E0"
  genesisBlockCreate "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config" "Group1Genesis"

  # Create directories to avoid permission errors on linux
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/config"
}

startNetwork() {
  printHeadline "Starting network" "U1F680"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker compose up -d)
  sleep 4
}

generateChannelsArtifacts() {
  printHeadline "Generating config for 'health-channel'" "U1F913"
  createChannelTx "health-channel" "$FABLO_NETWORK_ROOT/fabric-config" "HealthChannel" "$FABLO_NETWORK_ROOT/fabric-config/config"
}

installChannels() {
  printHeadline "Creating 'health-channel' on Doctor/peer0" "U1F63B"
  docker exec -i cli.doctor.healthcare.com bash -c "source scripts/channel_fns.sh; createChannelAndJoin 'health-channel' 'DoctorMSP' 'peer0.doctor.healthcare.com:7041' 'crypto/users/Admin@doctor.healthcare.com/msp' 'orderer0.group1.org1.healthcare.com:7030';"

  printItalics "Joining 'health-channel' on Patient/peer0" "U1F638"
  docker exec -i cli.patient.healthcare.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoin 'health-channel' 'PatientMSP' 'peer0.patient.healthcare.com:7061' 'crypto/users/Admin@patient.healthcare.com/msp' 'orderer0.group1.org1.healthcare.com:7030';"
}

installChaincodes() {
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/patient")" ]; then
    local version="1.0"
    printHeadline "Packaging chaincode 'patientcc'" "U1F60E"
    chaincodeBuild "patientcc" "golang" "$CHAINCODES_BASE_DIR/./chaincodes/patient" "16"
    chaincodePackage "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "patientcc" "$version" "golang" printHeadline "Installing 'patientcc' for Doctor" "U1F60E"
    chaincodeInstall "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "patientcc" "$version" ""
    chaincodeApprove "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" ""
    printHeadline "Installing 'patientcc' for Patient" "U1F60E"
    chaincodeInstall "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061" "patientcc" "$version" ""
    chaincodeApprove "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" ""
    printItalics "Committing chaincode 'patientcc' on channel 'health-channel' as 'Doctor'" "U1F618"
    chaincodeCommit "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" "peer0.doctor.healthcare.com:7041,peer0.patient.healthcare.com:7061" "" ""
  else
    echo "Warning! Skipping chaincode 'patientcc' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/patient'"
  fi

}

installChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "patientcc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/patient")" ]; then
      printHeadline "Packaging chaincode 'patientcc'" "U1F60E"
      chaincodeBuild "patientcc" "golang" "$CHAINCODES_BASE_DIR/./chaincodes/patient" "16"
      chaincodePackage "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "patientcc" "$version" "golang" printHeadline "Installing 'patientcc' for Doctor" "U1F60E"
      chaincodeInstall "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "patientcc" "$version" ""
      chaincodeApprove "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" ""
      printHeadline "Installing 'patientcc' for Patient" "U1F60E"
      chaincodeInstall "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061" "patientcc" "$version" ""
      chaincodeApprove "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" ""
      printItalics "Committing chaincode 'patientcc' on channel 'health-channel' as 'Doctor'" "U1F618"
      chaincodeCommit "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" "peer0.doctor.healthcare.com:7041,peer0.patient.healthcare.com:7061" "" ""

    else
      echo "Warning! Skipping chaincode 'patientcc' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/patient'"
    fi
  fi
}

runDevModeChaincode() {
  local chaincodeName=$1
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "patientcc" ]; then
    local version="1.0"
    printHeadline "Approving 'patientcc' for Doctor (dev mode)" "U1F60E"
    chaincodeApprove "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "health-channel" "patientcc" "1.0" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" ""
    printHeadline "Approving 'patientcc' for Patient (dev mode)" "U1F60E"
    chaincodeApprove "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061" "health-channel" "patientcc" "1.0" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" ""
    printItalics "Committing chaincode 'patientcc' on channel 'health-channel' as 'Doctor' (dev mode)" "U1F618"
    chaincodeCommit "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "health-channel" "patientcc" "1.0" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" "peer0.doctor.healthcare.com:7041,peer0.patient.healthcare.com:7061" "" ""

  fi
}

upgradeChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "patientcc" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/patient")" ]; then
      printHeadline "Packaging chaincode 'patientcc'" "U1F60E"
      chaincodeBuild "patientcc" "golang" "$CHAINCODES_BASE_DIR/./chaincodes/patient" "16"
      chaincodePackage "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "patientcc" "$version" "golang" printHeadline "Installing 'patientcc' for Doctor" "U1F60E"
      chaincodeInstall "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "patientcc" "$version" ""
      chaincodeApprove "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" ""
      printHeadline "Installing 'patientcc' for Patient" "U1F60E"
      chaincodeInstall "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061" "patientcc" "$version" ""
      chaincodeApprove "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" ""
      printItalics "Committing chaincode 'patientcc' on channel 'health-channel' as 'Doctor'" "U1F618"
      chaincodeCommit "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041" "health-channel" "patientcc" "$version" "orderer0.group1.org1.healthcare.com:7030" "OR('DoctorMSP.member', 'PatientMSP.member')" "false" "" "peer0.doctor.healthcare.com:7041,peer0.patient.healthcare.com:7061" "" ""

    else
      echo "Warning! Skipping chaincode 'patientcc' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/patient'"
    fi
  fi
}

notifyOrgsAboutChannels() {

  printHeadline "Creating new channel config blocks" "U1F537"
  createNewChannelUpdateTx "health-channel" "DoctorMSP" "HealthChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "health-channel" "PatientMSP" "HealthChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"

  printHeadline "Notyfing orgs about channels" "U1F4E2"
  notifyOrgAboutNewChannel "health-channel" "DoctorMSP" "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com" "orderer0.group1.org1.healthcare.com:7030"
  notifyOrgAboutNewChannel "health-channel" "PatientMSP" "cli.patient.healthcare.com" "peer0.patient.healthcare.com" "orderer0.group1.org1.healthcare.com:7030"

  printHeadline "Deleting new channel config blocks" "U1F52A"
  deleteNewChannelUpdateTx "health-channel" "DoctorMSP" "cli.doctor.healthcare.com"
  deleteNewChannelUpdateTx "health-channel" "PatientMSP" "cli.patient.healthcare.com"

}

printStartSuccessInfo() {
  printHeadline "Done! Enjoy your fresh network" "U1F984"
}

stopNetwork() {
  printHeadline "Stopping network" "U1F68F"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker compose stop)
  sleep 4
}

networkDown() {
  printHeadline "Destroying network" "U1F916"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker compose down)

  printf "Removing chaincode containers & images... \U1F5D1 \n"
  for container in $(docker ps -a | grep "dev-peer0.doctor.healthcare.com-patientcc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.doctor.healthcare.com-patientcc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.patient.healthcare.com-patientcc" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.patient.healthcare.com-patientcc*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done

  printf "Removing generated configs... \U1F5D1 \n"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/crypto-config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"

  printHeadline "Done! Network was purged" "U1F5D1"
}

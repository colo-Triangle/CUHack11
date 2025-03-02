#!/usr/bin/env bash

source "$FABLO_NETWORK_ROOT/fabric-docker/scripts/channel-query-functions.sh"

set -eu

channelQuery() {
  echo "-> Channel query: " + "$@"

  if [ "$#" -eq 1 ]; then
    printChannelsHelp

  elif [ "$1" = "list" ] && [ "$2" = "doctor" ] && [ "$3" = "peer0" ]; then

    peerChannelList "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041"

  elif
    [ "$1" = "list" ] && [ "$2" = "patient" ] && [ "$3" = "peer0" ]
  then

    peerChannelList "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061"

  elif
    [ "$1" = "list" ] && [ "$2" = "pool" ] && [ "$3" = "peer0" ]
  then

    peerChannelList "cli.pool.healthcare.com" "peer0.pool.healthcare.com:7081"

  elif
    [ "$1" = "list" ] && [ "$2" = "research" ] && [ "$3" = "peer0" ]
  then

    peerChannelList "cli.research.healthcare.com" "peer0.research.healthcare.com:7101"

  elif

    [ "$1" = "getinfo" ] && [ "$2" = "health-channel" ] && [ "$3" = "doctor" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "health-channel" "cli.doctor.healthcare.com" "peer0.doctor.healthcare.com:7041"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "health-channel" ] && [ "$4" = "doctor" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "health-channel" "cli.doctor.healthcare.com" "$TARGET_FILE" "peer0.doctor.healthcare.com:7041"

  elif [ "$1" = "fetch" ] && [ "$3" = "health-channel" ] && [ "$4" = "doctor" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "health-channel" "cli.doctor.healthcare.com" "${BLOCK_NAME}" "peer0.doctor.healthcare.com:7041" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "health-channel" ] && [ "$3" = "patient" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "health-channel" "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "health-channel" ] && [ "$4" = "patient" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "health-channel" "cli.patient.healthcare.com" "$TARGET_FILE" "peer0.patient.healthcare.com:7061"

  elif [ "$1" = "fetch" ] && [ "$3" = "health-channel" ] && [ "$4" = "patient" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "health-channel" "cli.patient.healthcare.com" "${BLOCK_NAME}" "peer0.patient.healthcare.com:7061" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "pool-patient" ] && [ "$3" = "patient" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "pool-patient" "cli.patient.healthcare.com" "peer0.patient.healthcare.com:7061"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "pool-patient" ] && [ "$4" = "patient" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "pool-patient" "cli.patient.healthcare.com" "$TARGET_FILE" "peer0.patient.healthcare.com:7061"

  elif [ "$1" = "fetch" ] && [ "$3" = "pool-patient" ] && [ "$4" = "patient" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "pool-patient" "cli.patient.healthcare.com" "${BLOCK_NAME}" "peer0.patient.healthcare.com:7061" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "pool-patient" ] && [ "$3" = "pool" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "pool-patient" "cli.pool.healthcare.com" "peer0.pool.healthcare.com:7081"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "pool-patient" ] && [ "$4" = "pool" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "pool-patient" "cli.pool.healthcare.com" "$TARGET_FILE" "peer0.pool.healthcare.com:7081"

  elif [ "$1" = "fetch" ] && [ "$3" = "pool-patient" ] && [ "$4" = "pool" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "pool-patient" "cli.pool.healthcare.com" "${BLOCK_NAME}" "peer0.pool.healthcare.com:7081" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "research-pool" ] && [ "$3" = "pool" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "research-pool" "cli.pool.healthcare.com" "peer0.pool.healthcare.com:7081"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "research-pool" ] && [ "$4" = "pool" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "research-pool" "cli.pool.healthcare.com" "$TARGET_FILE" "peer0.pool.healthcare.com:7081"

  elif [ "$1" = "fetch" ] && [ "$3" = "research-pool" ] && [ "$4" = "pool" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "research-pool" "cli.pool.healthcare.com" "${BLOCK_NAME}" "peer0.pool.healthcare.com:7081" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "research-pool" ] && [ "$3" = "research" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfo "research-pool" "cli.research.healthcare.com" "peer0.research.healthcare.com:7101"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "research-pool" ] && [ "$4" = "research" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfig "research-pool" "cli.research.healthcare.com" "$TARGET_FILE" "peer0.research.healthcare.com:7101"

  elif [ "$1" = "fetch" ] && [ "$3" = "research-pool" ] && [ "$4" = "research" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlock "research-pool" "cli.research.healthcare.com" "${BLOCK_NAME}" "peer0.research.healthcare.com:7101" "$TARGET_FILE"

  else

    echo "$@"
    echo "$1, $2, $3, $4, $5, $6, $7, $#"
    printChannelsHelp
  fi

}

printChannelsHelp() {
  echo "Channel management commands:"
  echo ""

  echo "fablo channel list doctor peer0"
  echo -e "\t List channels on 'peer0' of 'Doctor'".
  echo ""

  echo "fablo channel list patient peer0"
  echo -e "\t List channels on 'peer0' of 'Patient'".
  echo ""

  echo "fablo channel list pool peer0"
  echo -e "\t List channels on 'peer0' of 'Pool'".
  echo ""

  echo "fablo channel list research peer0"
  echo -e "\t List channels on 'peer0' of 'Research'".
  echo ""

  echo "fablo channel getinfo health-channel doctor peer0"
  echo -e "\t Get channel info on 'peer0' of 'Doctor'".
  echo ""
  echo "fablo channel fetch config health-channel doctor peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'Doctor'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> health-channel doctor peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'Doctor'".
  echo ""

  echo "fablo channel getinfo health-channel patient peer0"
  echo -e "\t Get channel info on 'peer0' of 'Patient'".
  echo ""
  echo "fablo channel fetch config health-channel patient peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'Patient'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> health-channel patient peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'Patient'".
  echo ""

  echo "fablo channel getinfo pool-patient patient peer0"
  echo -e "\t Get channel info on 'peer0' of 'Patient'".
  echo ""
  echo "fablo channel fetch config pool-patient patient peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'Patient'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> pool-patient patient peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'Patient'".
  echo ""

  echo "fablo channel getinfo pool-patient pool peer0"
  echo -e "\t Get channel info on 'peer0' of 'Pool'".
  echo ""
  echo "fablo channel fetch config pool-patient pool peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'Pool'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> pool-patient pool peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'Pool'".
  echo ""

  echo "fablo channel getinfo research-pool pool peer0"
  echo -e "\t Get channel info on 'peer0' of 'Pool'".
  echo ""
  echo "fablo channel fetch config research-pool pool peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'Pool'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> research-pool pool peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'Pool'".
  echo ""

  echo "fablo channel getinfo research-pool research peer0"
  echo -e "\t Get channel info on 'peer0' of 'Research'".
  echo ""
  echo "fablo channel fetch config research-pool research peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'Research'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> research-pool research peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'Research'".
  echo ""

}

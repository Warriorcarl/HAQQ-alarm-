#!/bin/bash

source $HOME/.bash_profile

DIR=$HOME/logs
LOG=$DIR/`basename $0 .sh`.log

echo "***" | tee -a $LOG;
echo `date` Start `basename $0 .sh` | tee -a $LOG;


BOT_TOKEN='5594922020:AAFakM_OLIy1fMN-IYmxkFoSO0gOx4EiZ6o'
#CHANNEL_ID="@snsmln_haqq"
CHANNEL_ID="-1001779145507"

##
DAEMON_STATUS=`systemctl status $DAEMON |grep Active | awk '{print $2}'`
#MONIKER=`$BIN q staking validator $VALOPER  | grep moniker | awk '{print $2}'`
POSITION=`$BIN q staking validators --limit=4000 -o json \
 | jq -r '.validators[] | select(.status=="BOND_STATUS_BONDED") | [(.tokens|tonumber / pow(10;6)), .description.moniker] | @csv' \
 | column -t -s"," | tr -d '"'| sort -k1 -n -r | nl | grep $MONIKER`
BLOCK_HIGHT=`curl -s localhost:26657/status 2> /dev/null | jq .result | jq -r .sync_info.latest_block_height`
PEERS=`curl -s http://localhost:$RPC_PORT/net_info 2> /dev/null | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr | split(":")[2])"' | wc -l`
STATUS_CURRENT=`$BIN q staking validator $VALOPER | grep status | awk '{print $2}'`
MISSING_BLOCKS=`$BIN q slashing signing-info $($BIN tendermint show-validator) | grep missed_blocks_counter | awk {'print $2'} | tr -d '"'`
JAILED=`$BIN q staking validator $VALOPER  | grep jailed | awk '{print $2}'`
VERSION=`$BIN version `

echo DAEMON_STATUS $DAEMON_STATUS | tee -a $LOG;
#echo MONIKER $MONIKER | tee -a $LOG;
echo POSITION $POSITION | tee -a $LOG;
echo BLOCK HIGHT $BLOCK_HIGHT | tee -a $LOG;
echo PEERS $PEERS | tee -a $LOG;
echo STATUS CURRENT $STATUS_CURRENT | tee -a $LOG;
echo MISSING BLOCKS: $MISSING_BLOCKS | tee -a $LOG;
echo JAILED $JAILED | tee -a $LOG;
echo VERSION $VERSION | tee -a $LOG;

MESSAGE_TEXT=" %0A
DAEMON: $DAEMON_STATUS
POSITION $POSITION
BLOCK HIGHT: $BLOCK_HIGHT
PEERS: $PEERS
STATUS: $STATUS_CURRENT
MISSING BLOCKS: $MISSING_BLOCKS
JAILED: $JAILED
VERSION: $VERSION
"

echo $MESSAGE_TEXT | tee -a $LOG;
# DATE $DATE %0A -d text=$TEXT | tee -a $LOG;

##
curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
-d chat_id=$CHANNEL_ID \
-d parse_mode="Markdown" \
-d text="$MESSAGE_TEXT" | tee -a $LOG;

echo "" | tee -a $LOG;

##
#killall -u $USER dbus-daemon

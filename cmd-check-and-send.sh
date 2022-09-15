#!/bin/bash


source $HOME/.bash_profile

DIR=$HOME/logs
LOG=$DIR/`basename $0 .sh`.log

echo "***" | tee -a $LOG;
echo `date` Start `basename $0 .sh` | tee -a $LOG;

BOT_TOKEN='***'
#CHANNEL_ID="@***"
CHANNEL_ID="-100***"

MIN_BLOCK_INC=5
MIN_PEERS=10
MAX_MISSING_BLOCKS=1

function status_send() {
##
    echo "Send status to TG" | tee -a $LOG;

} #status send


function message_send() {

    echo "Send message #$MESSAGE_TEXT# to TG" | tee -a $LOG;

    curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -d chat_id=$CHANNEL_ID \
    -d parse_mode="Markdown" \
    -d text="$MESSAGE_TEXT" | tee -a $LOG;

    ##
    ./cmd-send-message.sh;

} ##message_send



function message_send_save_prev_state() {
STATUS=$1
STATUS_OK=$2
PREV_STATE_FILE=$3
TEXT_ALARM=$4
TEXT_OK=$5

##
if [ ! -f $PREV_STATE_FILE ]; then echo "0" > $PREV_STATE_FILE; fi

if [[ $STATUS != $STATUS_OK ]]; then
    if [[ `cat $PREV_STATE_FILE` == "0" ]]; then
	MESSAGE_TEXT=$TEXT_ALARM ;
	message_send ;
        echo 1 > $PREV_STATE_FILE ;
    fi
    else 
        if [[ `cat $PREV_STATE_FILE` == "1" ]]; then
	    MESSAGE_TEXT=$TEXT_OK ;
            message_send ;
            echo 0 > $PREV_STATE_FILE ;
        fi
fi

} #function message_send_save_prev_state


##
cd $HOME/tg-bot

##
DAEMON_STATUS=`systemctl status $DAEMON |grep Active | awk '{print $2}'`
BLOCK_HIGHT=`curl -s localhost:26657/status 2> /dev/null | jq .result | jq -r .sync_info.latest_block_height`
PEERS=`curl -s http://localhost:$RPC_PORT/net_info 2> /dev/null | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr | split(":")[2])"' | wc -l`
STATUS_CURRENT=`$BIN q staking validator $VALOPER --keyring-backend test| grep status | awk '{print $2}'`
MISSING_BLOCKS=`$BIN q slashing signing-info $($BIN tendermint show-validator) | grep missed_blocks_counter | awk {'print $2'} | tr -d '"'`
JAILED=`$BIN q staking validator $VALOPER --keyring-backend test | grep jailed | awk '{print $2}'`
##VERSION=`$BIN version --keyring-backend test`


##
echo DAEMON_STATUS: $DAEMON_STATUS  | tee -a $LOG;
echo BLOCK_HIGHT: $BLOCK_HIGHT  | tee -a $LOG;
echo PREVIOUS_HIGHT: $PREVIOUS_HIGHT  | tee -a $LOG;
echo PEERS: $PEERS  | tee -a $LOG;
echo STATUS_CURRENT: $STATUS_CURRENT  | tee -a $LOG;
echo MISSING BLOCKS: $MISSING_BLOCKS | tee -a $LOG;
echo JAILED: $JAILED  | tee -a $LOG;

##
##Calculate current block hight increase
PREVIOUS_HIGHT=`cat state-hight.txt`
CALC_BLOCK_INC=`echo "$BLOCK_HIGHT - $PREVIOUS_HIGHT <= $MIN_BLOCK_INC " |bc -l`
echo CALC_BLOCK_INC: $CALC_BLOCK_INC | tee -a $LOG;
##SAVE CURRENT Block
echo $BLOCK_HIGHT>state-hight.txt

##
CALC_MIN_PEERS=`echo "$PEERS <= $MIN_PEERS " |bc -l`
echo CALC_MIN_PEERS: $CALC_MIN_PEERS | tee -a $LOG;

##
CALC_MAX_MISSING_BLOCKS=`echo "$MISSING_BLOCKS >= $MAX_MISSING_BLOCKS " |bc -l`
echo CALC_MAX_MISSING_BLOCKS: $CALC_MAX_MISSING_BLOCKS | tee -a $LOG;


## summary alarm
#if \
#	[[ $DAEMON_STATUS != "active" \
#	|| $CALC_BLOCK_INC == 1 \
#	|| $CALC_MIN_PEERS == 1 \
#7	|| $STATUS_CURRENT != "BOND_STATUS_BONDED" \
#	|| $JAILED == "true"  ]] ;

## test DAEMON_STATUS active | inactive
#DAEMON_STATUS=inactive
#PREV_STATE_FILE=state-daemon-status.txt ;
#if [[ $DAEMON_STATUS != "active" ]]; then
#    if [[ `cat $PREV_STATE_FILE` == "0" ]]; then
#	MESSAGE_TEXT="Alarm! Service not running" ;
#	message_send ;
#        echo 1 > $PREV_STATE_FILE ;
#    fi
#    else 
#        if [[ `cat $PREV_STATE_FILE` == "1" ]]; then
#	    MESSAGE_TEXT="Ok! Service running" ;
#            message_send ;
#            echo 0 > $PREV_STATE_FILE ;
#        fi
#fi

## test DAEMON_STATUS active | inactive
#DAEMON_STATUS=inactive
message_send_save_prev_state \
$DAEMON_STATUS \
"active" \
"state-daemon-status.txt" \
"⚠ Alarm! Service not running" \
"✅Ok! Service running" ;


##test CALC_BLOCK_INC = 0 | 1
#CALC_BLOCK_INC=1
message_send_save_prev_state \
$CALC_BLOCK_INC  \
"0" \
"state-block-hight.txt" \
"⚠ Alarm! Block hight slow up" \
"✅Ok! Block hight normal up" ;


## test MIN PEERS 0 | 1
#CALC_MIN_PEERS=1
message_send_save_prev_state \
$CALC_MIN_PEERS  \
"0" \
"state-peers-num.txt" \
"⚠ Alarm! Number of peers is low" \
"✅Ok! Number of peers is normal" ;





##test status BOND_STATUS_BONDED | BOND_STATUS_UNBONDED
#STATUS_CURRENT=BOND_STATUS_UNBONDED
message_send_save_prev_state \
$STATUS_CURRENT   \
"BOND_STATUS_BONDED" \
"state-validator-active.txt" \
"⚠ Alarm! Validator not active" \
"✅Ok! Validator in active set" ;


## test CALC_MAX_MISSING_BLOCKS 0 | 1
#CALC_MAX_MISSING_BLOCKS=1
message_send_save_prev_state \
$CALC_MAX_MISSING_BLOCKS  \
"0" \
"state-calc-max-missing-blocks.txt" \
"⚠ Alarm! Missing blocks more than $MAX_MISSING_BLOCKS " \
"✅Ok! Number of missing blocks is little than $MAX_MISSING_BLOCKS" ;



## test JAILED = "false" | "true"
#JAILED=true
message_send_save_prev_state \
$JAILED \
"false" \
"state-validator-jailed.txt" \
"⚠ Alarm! Validator in jail" \
"✅Ok! Validator escape from jail" ;


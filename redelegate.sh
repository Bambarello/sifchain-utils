#!/bin/bash

BIN_FILE="/root/go/bin/sifnodecli"
RPC_PORT="27657"
PASS="XXXXXXXXXXXX"
WALLET_NAME="sifchain"
CHAIN_ID="monkey-bars"
SELF_ADDR=$(echo $PASS | $BIN_FILE keys list -o json | jq -r .[0].address)
DENOM="rowan"
OPERATOR=$($BIN_FILE q staking delegations --chain-id $CHAIN_ID -o json --node tcp://localhost:$RPC_PORT $SELF_ADDR | jq -r .[].validator_address)

echo -e "Current address: $SELF_ADDR\nCurrent operator address: $OPERATOR"

while true;
do
    BALANCE=$($BIN_FILE query account $SELF_ADDR -o json --node tcp://localhost:$RPC_PORT | jq -r .value.coins[4].amount)
    echo CURRENT BALANCE IS: $BALANCE
    REWARD=$(( $BALANCE - 1000000 ))

    if (( $BALANCE >  3000000 )); then
        echo "Let's delegate $REWARD of REWARD tokens to $SELF_ADDR"
        # delegate balance
        echo -e "$PASS\n$PASS\n" | $BIN_FILE tx staking delegate $OPERATOR "$REWARD"$DENOM --chain-id $CHAIN_ID --node tcp://localhost:$RPC_PORT --gas-adjustment 1.5 --gas="200000" --fees 7500$DENOM --from $WALLET_NAME -y

    else
        echo "Reward is $REWARD"
    fi
    sleep 500
done
echo "DONE"

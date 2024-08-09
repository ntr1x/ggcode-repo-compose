#!/bin/bash

WORK_DIR=/app/work
DATA_DIR=/app/data
SOURCE_DIR=${WORK_DIR}/source
TARGET_DIR=${WORK_DIR}/target

cursor=0

cleanup () {
    tail -n +$((cursor+1)) $DATA_DIR/messages.pack > $DATA_DIR/messages.bak
    rm -f $DATA_DIR/messages.pack
    rm -f $DATA_DIR/messages.pipe
    if [[ ! -s $DATA_DIR/messages.bak ]]; then
        rm -f $DATA_DIR/messages.bak
    fi
    exit 130
}

trap cleanup SIGINT

mkdir -p $DATA_DIR
mkdir -p $WORK_DIR

while true; do
    mcli alias set minio $MINIO_TARGET_SERVER $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
    if [[ $? == 0 ]]; then
        break
    else
        echo "Minio is down. Sleep for $MINIO_THROTTLE_INTERVAL second(s)" >&2
        sleep $MINIO_THROTTLE_INTERVAL
    fi
    test $? -gt 128 && break;
done

if [[ ! -e $DATA_DIR/messages.pipe ]]; then
    mkfifo $DATA_DIR/messages.pipe
fi

while true; do

    cursor=0

    if [[ -e $DATA_DIR/messages.bak ]]; then
        mv $DATA_DIR/messages.bak $DATA_DIR/messages.pack
        cat $DATA_DIR/messages.pack > $DATA_DIR/messages.pipe &
    else
        kcat -C -u \
            -c $KAFKA_CONSUMER_FETCH_COUNT \
            -b $KAFKA_BOOTSTRAP_SERVERS \
            -G $KAFKA_CONSUMER_GROUP \
            -X auto.offset.reset=$KAFKA_CONSUMER_AUTO_OFFSET_RESET \
            -X group.instance.id=$KAFKA_CONSUMER_GROUP_INSTANCE_ID \
            $KAFKA_TOPICS \
            | jq --unbuffered -r '[.EventName, .Key] | @sh' \
            | tee $DATA_DIR/messages.pack \
            > $DATA_DIR/messages.pipe &
    fi

    active=false

    while read line; do

        active=true

        echo $line | xargs -n2 sh \
            -c 'EVENT_NAME=$0 OBJECT_KEY="$1" SOURCE_DIR='"$SOURCE_DIR"' TARGET_DIR='"$TARGET_DIR"' /bin/bash ./bin/process.sh'

        ((cursor++))

        test $? -gt 128 && break;

    done < $DATA_DIR/messages.pipe

    test $? -gt 128 && break;

    if [[ $active == false ]]; then
        echo "Kafka is down. Sleep for $KAFKA_THROTTLE_INTERVAL second(s)" >&2
        sleep $KAFKA_THROTTLE_INTERVAL
    fi
done

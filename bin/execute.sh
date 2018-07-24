#!/bin/bash

PROJECT='demo'
PROFILE='swfz'

if [ ! -n "$1" ]; then
  echo 'prease input role'
  exit 1
fi

if [ ! -n "$2" ]; then
  echo 'prease input action'
  exit 1
fi

case "$2" in
  create)
    ACTION='create-stack'
  ;;
  check)
    # TODO 対応する
    # aws: error: the following arguments are required: --change-set-name
  ACTION='create-change-set'
  ;;
  update)
    ACTION='update-stack'
esac

role=$1


exec_pvc(){
  aws --profile ${PROFILE} cloudformation ${ACTION} \
    --stack-name ${PROJECT}-${role} \
    --template-body file://$(pwd)/${role}-template.yml \
    --parameters \
    ParameterKey=AZ1Parameter,ParameterValue=ap-northeast-1a \
    ParameterKey=AZ2Parameter,ParameterValue=ap-northeast-1c \
    ParameterKey=ProjectNameParameter,ParameterValue=${PROJECT^}
}

exec_db(){
  aws --profile ${PROFILE} cloudformation ${ACTION} \
    --stack-name ${PROJECT}-${role} \
    --template-body file://$(pwd)/${role}-template.yml \
    --parameters \
    ParameterKey=ProjectNameParameter,ParameterValue=${PROJECT^} \
    ParameterKey=RDSInstanceTypeParameter,ParameterValue=db.t2.small \
    ParameterKey=RDSUserParameter,ParameterValue=root \
    ParameterKey=RDSPasswordParameter,ParameterValue=aaaabbbbcccc
}

exec_redis(){
  aws --profile ${PROFILE} cloudformation ${ACTION} \
    --stack-name ${PROJECT}-${role} \
    --template-body file://$(pwd)/${role}-template.yml \
    --parameters \
    ParameterKey=AZ1Parameter,ParameterValue=ap-northeast-1a \
    ParameterKey=ProjectNameParameter,ParameterValue=${PROJECT^} \
    ParameterKey=RedisInstanceTypeParameter,ParameterValue=cache.t2.micro
}



case "${role}" in
  vpc)
    exec_pvc
  ;;
  db)
    exec_db
  ;;
  redis)
    exec_redis
esac



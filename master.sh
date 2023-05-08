#!/usr/bin/env bash

function validar_keepalived(){
        KEP=""
        KEP=$(docker ps -qf name=keepalived)
        echo "En espera de keepalived.."
        sleep 10
        remover_keepalived $KEP
}

function remover_keepalived(){
        if [ "$1" != "" ]; then
                echo "keepalived esta activo, eliminando..."
                docker rm keepalived --force
                sleep 10
                echo "keepalived removido..."
        fi
}

function validar_ips(){
  ip_tierra=""
  ip_mercurio=""
  until [ "$ip_tierra" != "" ] && [ "$ip_mercurio" != "" ]; do
      ip_tierra=$(ssh tierra1@tierra ifconfig eno1 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| head -n 1)
            ip_mercurio=$(ifconfig eno2 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| head -n 1)
            echo "tierra: $ip_tierra, mercurio: $ip_mercurio"
  done
        despliegue_keepalived $ip_tierra $ip_mercurio
}

function despliegue_keepalived(){
        docker run -d --name keepalived --restart=always \
                --cap-add=NET_ADMIN --cap-add=NET_BROADCAST --cap-add=NET_RAW --net=host \
                -e KEEPALIVED_INTERFACE=enp0s20u1 \
                -e KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:[$1,$2]" \
                -e KEEPALIVED_VIRTUAL_IPS=148.226.80.161 \
                -e KEEPALIVED_PRIORITY=200 \
                osixia/keepalived
        exit;
}



function main(){
        sleep 15
        validar_keepalived
        validar_ips
}

sleep 10

main

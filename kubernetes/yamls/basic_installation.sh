#!/bin/bash
echo  -e "\033[5m---------------------------- X2Go server, Anydesk and FRPC installation -------------------------------------\033[0m"

str1="'"
echo -e $'\e[0;33m'Plz enter Atm Id : $'\e[0m'
read atm_id
echo""
echo -e $'\e[0;33m'Plz enter verification Key : $'\e[0m'
read verify_key
echo""


verify_atm(){
        atm_var="$str1$atm_id$str1"
        free="free"
        free="$str1$free$str1"
        verify_key="$str1$verify_key$str1"

        token=$(curl -X POST https://pivotchain.in/event-app/get_token -H 'Content-Type: application/json' -d '{"username":"custedge@gmail.com","password": "custedge"}')
        #echo $token
        tok=$(echo "$token" | jq .token| tr -d '"')


        data=$(curl -X POST https://pivotchain.in/event-app/fetch_atm/kotak_banking/custedge@gmail.com?token=$tok -H 'Content-Type: application/json' -d '{"db_name":"raven","condition":"atm_id='${atm_var}' and atm_id_status='${free}' and verification_key='${verify_key}'"}')

        #echo $data
        country=$(echo "$data" | jq -r '.atm[]|"\(.country)"' | head -n 1)
        echo $country
        if test -z "$country";
        then
                echo -e $'\e[0;31m'ATM_ID is already in use plz check atm_id and verification key$'\e[0m'
                exit
        else
                echo -e $'\e[0;32m'ATM_ID verified sucessfully...!$'\e[0m'
        fi
}


installation_script(){

	useradd -m -d /home/raven -s /bin/bash raven
        echo -e "Pivo8Chain@35\nPivo8Chain@35\n" | passwd raven
        sed -i -e '/privilege specification/a raven ALL=(ALL) NOPASSWD:ALL' /etc/sudoers
        echo "----RAVEN user added -----$?"
        systemctl enable anydesk
        echo $atm_id | sudo anydesk --set-password
        
        atm_var="$str1$atm_id$str1"
        
        #echo $atm_var

        token=$(curl -X POST https://pivotchain.in/event-app/get_token -H 'Content-Type: application/json' -d '{"username":"custedge@gmail.com","password": "custedge"}')
        #echo $token

        tok=$(echo "$token" | jq .token| tr -d '"')
        data=$(curl -X POST https://pivotchain.in/event-app/fetch_atm/kotak_banking/custedge@gmail.com?token=$tok -H 'Content-Type: application/json' -d '{"db_name":"raven","condition":"atm_id='${atm_var}'"}')

        SSHPORT=$(echo "$data" | jq -r '.atm[]|"\(.app_url_details["ssh_port"])"' | head -n 1)
        
        echo "frpc changes"
        cp -r /usr/local/k8_client/frpc /etc/
        cp -r /etc/frpc/frpc /usr/bin/
        chmod 777 /usr/bin/frpc
        sed -i 's/SSHPORT/'"$SSHPORT"'/g' /etc/frpc/frpc.ini
        sed -i 's/ssh/ssh'"$atm_id"'/g' /etc/frpc/frpc.ini
        sed -i 's/web/web'"$atm_id"'/g' /etc/frpc/frpc.ini 
	sed -i 's/SUBDOMAIN/'"$atm_id"'/g' /etc/frpc/frpc.ini
	cp -r /etc/frpc/frpc.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl start frpc.service
	systemctl  enable frpc.service
	echo "FRPC service started  --> $?"

}

verify_atm ##########Verify atm id with key
echo ""
installation_script ##########Basic installation
echo ""

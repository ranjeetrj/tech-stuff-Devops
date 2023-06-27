#!/bin/bash
echo  -e "\033[5m------------------------------------------ WELCOME TO RAVEN ------------------------------------------\033[0m"

str1="'"
echo -e $'\e[0;33m'Plz enter Atm Id : $'\e[0m'
read atm_id
echo""

verify_atm(){
        cat /etc/frpc/frpc.ini | grep $atm_id
	if [ $? -eq 0 ]; then
                echo -e $'\e[0;32m'ATM_ID verified sucessfully...!$'\e[0m'
        else
                echo -e $'\e[0;31m'ATM_ID is differnet please check /etc/frpc/frpc.ini file$'\e[0m'
                exit
        fi
}

start_script(){

	echo $'\e[0;33m'--------------------------STARTED SETUP.SH SCRIPT-----------------------------$'\e[0m'
	echo ""
	#useradd -m -d /home/raven -s /bin/bash raven
        #echo -e "Pivo8Chain@35\nPivo8Chain@35\n" | passwd raven
        #sed -i -e '/privilege specification/a raven ALL=(ALL) NOPASSWD:ALL' /etc/sudoers
	#echo "----RAVEN user added -----$?"
        echo "----Script exection started-----"
        mkdir -p /mnt/ravenfs/pivotchain
        echo " /mnt/ravenfs/pivotchain directory created --> $? "
        mv ../../k8_client /mnt/ravenfs/pivotchain
        cd /mnt/ravenfs/pivotchain/k8_client/yamls
        echo "Now in /mnt/ravenfs/pivotchain/k8s_client/yaml path"
        echo""
 
	atm_var="$str1$atm_id$str1"
        sshpass -p 'Pivo8Chain@35' ssh -p 55200 -o "StrictHostKeyChecking no" raven@$wifi_ip pactl load-module module-native-protocol-tcp port=34567 auth-ip-acl=10.244.0.0/16

	#echo $atm_var

	token=$(curl -X POST https://pivotchain.in/event-app/get_token -H 'Content-Type: application/json' -d '{"username":"custedge@gmail.com","password": "custedge"}')
	#echo $token

	tok=$(echo "$token" | jq .token| tr -d '"')

	data=$(curl -X POST https://pivotchain.in/event-app/fetch_atm/kotak_banking/custedge@gmail.com?token=$tok -H 'Content-Type: application/json' -d '{"db_name":"raven","condition":"atm_id='${atm_var}'"}')

	#echo $data

	registry_server=$(echo "$data" | jq -r '.docker[]|"\(.registry_name)"' | head -n 1)
	#echo $registry_server

	client_name=$(echo "$data" | jq -r '.docker[]|"\(.client_name)"' | head -n 1)
	#echo $client_name


	registry_user=$(echo "$data" | jq -r '.docker[]|"\(.username)"' | head -n 1)
	#echo $registry_user

	build_id=$(echo "$data" | jq -r '.docker[]|"\(.tag)"' | head -n 1)
	#echo $build_id


	registry_pass=$(echo "$data" | jq -r '.docker[]|"\(.password)"' | head -n 1)

	device_id=$(echo "$data" | jq -r '.atm[]|"\(.device_id)"' | head -n 1)
	#echo $device_id


	key=$(echo "$data" | jq -r '.atm[]|"\(.key)"' | head -n 1)
	#echo $key

        SSHPORT=$(echo "$data" | jq -r '.atm[]|"\(.app_url_details["ssh_port"])"' | head -n 1)


}



#------------------------------------------------------ PRINT LAN AND WIFI IP -------------------------------------------#####

print_ips(){
lan_ip=$(ip a| grep eno | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
echo -e $'\e[0;33m'LAN IP4 : $'\e[1;36m' $lan_ip $'\e[0m'
echo ""

wifi_ip=$(ip a | grep enx | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
echo -e $'\e[0;33m'WiFi IP4 :$'\e[1;36m' $wifi_ip$'\e[0m'
echo ""
}

#--------------------------------------------------------  Check Internet  -----------------------------------------------------------####

check_internet(){
if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
  echo -e $'\e[0;32m'Internet is Up$'\e[0m'
  echo ""
  setiprules
else
  echo -e $'\e[0;31m'Internet is down $'\e[0m'
  exit
fi

echo "updating the cron"
crontab -l > cron_bkp
echo "* */1 * * * /bin/bash /mnt/ravenfs/pivotchain/k8_client/update-rc.sh >/tmp/cronlogs 2>&1" >> cron_bkp
crontab cron_bkp
rm cron_bkp
echo "cron updated successfully --> $?"
mv /usr/local/k8_client/Raven-Client\ Installation.pdf  /home/raven
chown -R raven:raven /usr/local/k8_client/Raven-Client\ Installation.pdf
echo "Raven Installation Doc moved in raven-user --->$?"
}




#-------------------------------------------------------  Kubernetes Cluster Setup ------------------------------------------------------------------####

setkube(){
	
	sudo sed -i 's/ATM_ID/'"$atm_id"'/g' /mnt/ravenfs/pivotchain/k8_client/yamls/keel-service.yaml 
	echo "ATM_ID replace in keel-service.yaml ----> $?"
	echo "ssh pem file setup started"
	sudo mkdir /home/raven/.ssh/
	sudo chmod 700 /home/raven/.ssh/
        sudo cat /mnt/ravenfs/pivotchain/k8_client/yamls/ssh_key/first_public_key.pub > /home/raven/.ssh/authorized_keys
        sudo cat /mnt/ravenfs/pivotchain/k8_client/yamls/ssh_key/second_public_key.pub >> /home/raven/.ssh/authorized_keys
	sudo chmod 600  /home/raven/.ssh/authorized_keys
	sudo chown -R raven:raven /home/raven/.ssh/
	echo "2 public key added  --> $?"
	

	echo -e $'\e[0;32m'KUBERNETES CLUSTER CREATING  .......$'\e[0m'

	cd /mnt/ravenfs/pivotchain/k8_client/yamls
        echo""
	sudo sed -i '/swap/d' /etc/fstab
	echo "Disabled swap permanently "
        sudo swapoff -a
        #Starting Kubeadm
        sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$lan_ip --kubernetes-version=v1.23.5
        echo "kubeadm init command executed successfully --> $? "
        #Configuration
        mkdir -p $HOME/.kube
        sudo cp -rf /etc/kubernetes/admin.conf $HOME/.kube/config 
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

	sudo bash -c 'echo "serializeImagePulls: false" >> /var/lib/kubelet/config.yaml'
        sudo systemctl restart kubelet.service
	sleep 10s
	sudo sed -i 's%Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"%Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml --node-ip='$lan_ip'"%g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	sudo systemctl daemon-reload
        sudo systemctl restart kubelet
	echo "kubelet config updated -->$?"

        #Install Flannel for pod networking
        sudo kubectl apply  -f ../kube-flannel.yml
	#sudo kubectl apply -f ../calico.yaml

        echo "Deployed flannel network plugin --> $?"
        sleep 10
        #Untaint the master so you can run pods
        sudo kubectl taint nodes --all node-role.kubernetes.io/master-
        echo "tainted master node to deploy the applications --> $?"
#        sudo mkdir -p /mnt/ravenfs/pivotchain/
	#dbtar
	sudo tar -xvzf mongodb.tar.gz -C /mnt/ravenfs/pivotchain/
	echo "dbata successfully extracted --> $?"
	sudo mv mongodb.tar.gz /mnt/ravenfs/pivotchain/
        echo "/mnt/ravenfs/pivotchain/ directory created --> $? "
        sudo cp -rf $HOME/.kube/config /mnt/ravenfs/pivotchain/kubeconfig
        echo "Copied config file into /mnt/ravenfs/pivotchain/ --> $? "
	echo $PWD
	#kubectl apply -f dns.yaml
	#echo "dns deployed successfully"
	#cat ../cronjob.yaml | sed "s/{{build_id}}/$build_id/g"|sed "s/{{client_name}}/$client_name/g"|sed "s/{{registry_server}}/$registry_server/g" |sudo kubectl apply -f -
	#echo "cronjob deployed successfully"
	kubectl apply -f keel-service.yaml
	echo "keel deployed successfully"
	sleep 30s
	kubectl -n keel get pods
        k_time=$(date +%s)
        k_end_time=$((k_time+1500))	
	while true;
	do
	sleep 10
        unset content
        content+=$(echo $(sudo kubectl get po -n kube-system | awk '{print $3}' | tail -n +2))
        nodes=`sudo kubectl get po -n kube-system | wc -l`
        nodes=$((nodes-1))
	k_time=$(date +%s)
	#echo $k_time
        flag=0
        echo $content
        for i in ${content[@]};
        do
        echo $i
                if [[ $i == "Running" || $i == "Completed"  ]];
                then
                        flag=$((flag+1))
                        if [[ $flag -eq $nodes ]]
                        then
                                echo -e $'\e[0;32m'Kubernetes Cluster Created Sucessfully....!!!$'\e[0m'
				temp=$((temp+1))
				break 2
                        fi
                elif [[ $i == "ContainerCreating" || $i == "Pending" || $i == "PodInitializig" ]];
                then
                        if [[ $k_time -le $k_end_time ]];then
                                echo "Kube-system pods are not deployed yet"
                                break
                        else
                                echo -e $'\e[0;31m'Kubernetes Cluster not Created plz Check the pods of kube-system running or not $'\e[0m'
                                exit
                        fi

        
                else

 			echo -e $'\e[0;31m'Kubernetes Cluster not Created plz Check the pods of kube-system running or not $'\e[0m'
			exit

                fi
        done
done
echo ""
echo ""

}


#------------------------------------------------------------   Extract Docker Images   -------------------------------------------------------------####

extdoc(){
        echo -e  $'\e[0;32m'EXTRACTING  DOCKER IMAGES .........$'\e[0m'
	echo ""
	directory=`pwd`
	cd ../images
	ls | grep tar > files.txt
	c=0
	printf "START \n"
	input="../images/files.txt"
	while IFS= read -r line
	do
     	c=$((c+1))
     	printf "$c) $line \n"
     	sudo docker load -i $line
        echo -e $'\e[0;32m' Docker images Extractracting.....$'\e[0m'--> $?
	ret=$?
	done < "$input" 
	sudo rm files.txt
	if [ $ret -eq 0 ]
	then
		echo  $'\e[0;32m'------------------------ Docker images Extracted Sucessfully.... $'\e[0m'
	else 
		echo  $'\e[0;31m'Docker Images Not Exracted Succestully..... $'\e[0m'
	fi
					
	echo ""

}





#-----------------------------------------------------------  Deploy Base Services  -----------------------------------------------------------------####

deploy(){


	cd /mnt/ravenfs/pivotchain/k8_client/yamls
	echo -e  $'\e[0;32m' -----------------------------  DEPLOYING DASHBOARD SERVICES... ----------------------------  $'\e[0m'


        	echo Proceeded with the deployment
docker login $registry_server -u="$registry_user" -p="$registry_pass"		

		
	                      
	      
echo ""
#sudo kubectl apply -f ../dashboard/recommended.yaml
#sudo kubectl apply -f ../dashboard/working-metricserver.yaml
#sudo kubectl apply -f ../dashboard/dashboard-admin.yaml
if [[ $? -eq 0 ]];then
	echo $'\e[0;32m'------------------------- Dashboard services deployed successfully...!!! ------------------------ $'\e[0m'
else
	echo $'\e[0;31m'------------------------- Dashboard services not deployed....!!! ----------------------- $'e[0m'
fi
echo ""
echo ""

sleep 5s


	echo -e  $'\e[0;32m' -----------------------------  DEPLOYING BASE SERVICES... ----------------------------  $'\e[0m'

kubectl create secret generic raven-registry  --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson
echo "docker registry secret created successfully --> $?"
kubectl apply -f mongodb-secrets.yaml
echo "mongo secret created successfully --> $?"
#sudo rm -rf mongodb-secrets.yaml



			## ------------ CREATING CONFIG POD ----------- ##
	sudo kubectl get configmap |grep backend-config
	if [ $? == 0 ];
	then
		sudo kubectl delete configmap backend-config ffmpeg-yaml frontend-config kubeconfig raven-yaml
		sudo cat config.yaml | sed "s/{{build_id}}/$build_id/g"|sed "s/{{client_name}}/$client_name/g"|sed "s/{{registry_server}}/$registry_server/g" |kubectl apply -f -
                sleep 10s
		echo $'\e[1;31m'Already created configmap deleted and newly created $'\e[0m'
	else
		#kubectl apply -f config.yaml
		sudo cat config.yaml | sed "s/{{build_id}}/$build_id/g"|sed "s/{{client_name}}/$client_name/g"|sed "s/{{registry_server}}/$registry_server/g" |kubectl apply -f -
		echo "creating configmap "
		sleep 10s
	#while [ `kubectl get pods |grep config |grep Running >> /dev/null ;echo $?` -eq 0 ]; do
	#	a=`kubectl get pods |grep config | awk -F " " '{print $3}'`
	#	echo $a
	#done
 strmatch="All configmaps created"
 runmatch="Running"
 c_time=$(date +%s)
 c_end_time=$((c_time+1000))

 while true
 do
	 c_time=$(date +%s)
         pod=$(kubectl get po | awk {'print$1'} | grep config )
         run=$(kubectl get pods | awk '{print $3}' | tail -n 1)
         check=$(kubectl logs $pod | tail -n 1)
         #kubectl logs -f $pod
         if [[ $c_time -le $c_end_time ]];
         then
		 if [[ $run == $runmatch  &&  $check == $strmatch ]];
		 then
			 echo $'\e[0;32m'Stream matched, Config Pod Created Successfully...$'\e[0m'
                         break
		 else
                         echo "Configmaps pod not Created Yet..."    
		 fi
	 else
		 echo -e $'\e[0;31m'Time Exceeded plz Check !!!..$'\e[0m'
                 exit
	 fi
done


fi

sleep 20s

#echo "Image updation in configmap successfully --> $?"

	
                             ##*************** NGINX INGRESS SVC *****************##
sudo kubectl apply -f nginx-ingress-svcs.yaml
#echo  $'\e[1;31m' create nginx-ingress-svcs $'\e[0m'
runmatch="Running"
readymatch="1/1"
c_time=$(date +%s)
c_end_time=$((c_time+1000))

 while true
 do
         c_time=$(date +%s)
	 ready=$(kubectl get po -n ingress-nginx | grep controller | awk '{print $2}')
         run=$(kubectl get po -n ingress-nginx | grep controller | awk '{print $3}')
	 if [[ $c_time -le $c_end_time ]];
         then
                 if [[ $run == $runmatch  &&  $ready == $readymatch ]];
                 then
                         echo $'\e[0;32m'NginxIngress Pods, deployed successfully and in Running Successfully...$'\e[0m'
                         break
                 else
			 sleep 5s
                         echo "Nginx Ingress pod not in Ready State"
			 echo $ready
                 fi
         else
                 echo -e $'\e[0;31m'Time Exceeded plz Check Nginxingress pods. If it is Running and Ready then apply back-front-nginx-ingress.yaml file !!!..$'\e[0m'
                 exit
         fi
 done


			     ##**************** RAVEN APP *************##

cat base-services.yaml | sed "s/{{build_id}}/$build_id/g"|sed "s/{{client_name}}/$client_name/g"|sed "s/{{registry_server}}/$registry_server/g" |sudo kubectl apply -f -

#cat config.yaml | sed "s/{{build_id}}/$build_id/g"|sed "s/{{client_name}}/$client_name/g"|sed "s/{{registry_server}}/$registry_server/g" |sudo kubectl apply -f -

#                             ##************** BACK-FRONTEND INGRESS *************##
#sleep 40s
#sudo kubectl apply -f back-front-nginx-ingress.yaml
#echo  $'\e[1;31m' back-front-nginx-ingress  $'\e[0m'

echo  $'\e[1;31m' raven app $'\e[0m'
                             ##############################  Pod Running Status Cheking ####################

k_time=$(date +%s)
k_end_time=$((k_time+1000))
while true;
do
	sleep 10
        unset content
        content+=$(echo $(sudo kubectl get po | awk '{print $3}' | tail -n +2))
        nodes=`sudo kubectl get po | wc -l`
        nodes=$((nodes-1))
        flag=0
	k_time=$(date +%s)
        echo $content
        for i in ${content[@]};
        do
        echo $i
                if [[ $i == "Running" || $i == "Completed"  ]];
                then
                        flag=$((flag+1))
                        if [[ $flag -eq $nodes ]]
                        then
                                echo $'\e[0;32m'----------------------------- Base services pods Are Deployed Sucessfully....!!! ------------------------- $'\e[0m'
                                break 2
                        fi
                elif [[ $i == "ContainerCreating" || $i == "Pending" || $i == "PodInitializig" || $i == "ImagePullBackOff" || $i == "ErrImagePull" ]];
                then
			if [[ $k_time -le $k_end_time ]];then
                                echo "Base Service pods are not deployed yet"
                                break
                        else
                                echo -e $'\e[0;31m'Pods are not Deployed Properly..... Plz Check Base service running or not $'\e[0m'
                                exit
			fi
			
                else
			echo -e $'\e[0;31m'------------------------- Base services pods are not Deployed Properly..Plz Check...! -------------------------$'\e[0m'
			exit
			
                fi
        done
done

echo ""
echo ""
}




##---------------------------------------------------- Setting Up Iptables Rules --------------------------------------------------------------------####

setiprules(){

echo -e $'\e[0;32m'------------------------- Setting up the Firewall Rules... ------------------------- $'\e[0m'

sudo ufw allow from 20.197.30.56 to any port 55200
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo ufw allow 443/tcp
sudo ufw allow 6443/tcp
sudo ufw allow 2379/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10255/tcp
sudo ufw allow 10256/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp
sudo ufw allow 2380
sudo ufw allow 80
sudo ufw allow 8080
sudo ufw allow 8088
sudo ufw allow in on flannel.1 && sudo ufw allow out on flannel.1
sudo ufw allow in on cni0 && sudo ufw allow out on cni0

echo -e $'\e[0;32m'------------------------- Firewalls Rules update Successfully.... ------------------------- $'\e[0m'
echo ""
}



##------------------------------------------------------------- Mongo_Script ------------------------------------------------------------------------####
mongo_scr(){
	echo -e $'\e[0;32m'------------------------------- Fetching User Detalis.... --------------------------------$'\e[0m'
	atm_var="$str1$atm_id$str1"
	#echo $registry_pass
	#echo $registry_user
	#echo $atm_var

	token=$(curl -X POST https://pivotchain.in/event-app/get_token -H 'Content-Type: application/json' -d '{"username":"custedge@gmail.com","password": "custedge"}')
	echo $token

	tok=$(echo "$token" | jq .token| tr -d '"')


	data=$(curl -X POST https://pivotchain.in/event-app/fetch_atm/kotak_banking/custedge@gmail.com?token=$tok  -H 'Content-Type: application/json' -d '{"db_name":"raven","condition":"atm_id='${atm_var}'"}')

	#echo $data

        echo $data > json
	
	mongo_pod=`sudo kubectl get po | awk '{print $1}' |  grep mongo`
	pwd
	
        jq .atm json  | sed 's/[][]//g' > /mnt/ravenfs/pivotchain/mongodb/atm.json
	jq .cust json  | sed 's/[][]//g' > /mnt/ravenfs/pivotchain/mongodb/userdetails.json
	jq .license json  | sed 's/[][]//g' > /mnt/ravenfs/pivotchain/mongodb/license.json
	jq .secret json  | sed 's/[][]//g' > /mnt/ravenfs/pivotchain/mongodb/secret.json



	sudo kubectl exec  $mongo_pod -- mongoimport --db raven --collection atm_details --authenticationDatabase admin --username $registry_user --password $registry_pass --drop --file  /data/db/atm.json

	sudo kubectl exec  $mongo_pod -- mongoimport --db raven --collection userdetails --authenticationDatabase admin --username $registry_user --password $registry_pass  --drop --file /data/db/userdetails.json
	
	sudo kubectl exec  $mongo_pod -- mongoimport --db raven --collection license --authenticationDatabase admin --username $registry_user --password $registry_pass  --drop --file /data/db/license.json
	
	sudo kubectl exec  $mongo_pod -- mongoimport --db raven --collection secret --authenticationDatabase admin --username $registry_user --password $registry_pass  --drop --file /data/db/secret.json
	ret=$?
	sudo rm json	
	sudo rm -rf /mnt/ravenfs/pivotchain/mongodb/userdetails.json
	sudo rm -rf /mnt/ravenfs/pivotchain/mongodb/atm.json
	sudo rm -rf /mnt/ravenfs/pivotchain/mongodb/license.json
	sudo rm -rf /mnt/ravenfs/pivotchain/mongodb/secret.json

	if [ $ret -eq 0 ]
	then
		echo $'\e[0;32m'----------------------- User Details Fetched Successfully...!!! ------------------------- $'\e[0m'
	else
		echo $'\e[0;31m'----------------------- User Details not Fetched Properly....!!! ------------------------ $'\e[0m'
	 

	fi
	docker logout $registry_server


	                             ##************** BACK-FRONTEND INGRESS ***********
sudo kubectl apply -f back-front-nginx-ingress.yaml
#echo  $'\e[1;31m' back-front-nginx-ingress  $'\e[0m'


}

grub_pass(){
#cp /etc/grub.d/40_custom /etc/grub.d/40_custom.old

#echo 'set superusers="raven"' >> /etc/grub.d/40_custom

#echo -e 'Pivo8Chain\nPivo8Chain' | grub-mkpasswd-pbkdf2 | awk '/grub.pbkdf/{print$NF}' >> /etc/grub.d/40_custom

#sed -i 's/grub/password_pbkdf2 raven grub/g' /etc/grub.d/40_custom

#grub-mkconfig -o /boot/grub/grub.cfg

sudo bash /mnt/ravenfs/pivotchain/k8_client/port_block.sh
echo "updating the cron"
crontab -l > ramclean
echo "*/10 * * * * /bin/bash /mnt/ravenfs/pivotchain/k8_client/ram_clean.sh >/tmp/ramclean 2>&1" >> ramclean
crontab ramclean
rm ramclean
echo "cron updated successfully --> $?"
}

#*******************************************************************************************************************************************************#

#--------------------------------------------------------  Calling functions -----------------------------------------------------------####

verify_atm ##########Verify atm id with key
echo ""
check_internet	 ###### For checking the internet // starting nabto service  
echo ""
print_ips       ###### Print LAN and WIFI IP
echo""
start_script ######  apt-update, install apps, fetch docker registry details
echo""
#setiprules 	###### It will set ufw/IPtables rules
echo""
extdoc 		###### For extracting docker image
echo ""
setkube 	###### Setup of kubernetes cluster
echo ""
deploy 		######## For deploying raven base service
echo ""
mongo_scr 	 ############ Insert entry in mongodb
echo ""
grub_pass
echo ""

#--------------------------------------------------------  FINAL VALIDATION -----------------------------------------------------------####
while true;
do
        sleep 20
        unset content
        content+=$(echo $(sudo kubectl get po | awk '{print $3}' | tail -n +2))
        nodes=`sudo kubectl get po | wc -l`
        nodes=$((nodes-1))
        flag=0
        #echo $content
        for i in ${content[@]};
        do
        #echo $i
                if [[ $i == "Running" || $i == "Completed"  ]];
                then
                        flag=$((flag+1))
                        if [[ $flag -eq $nodes ]]
                        then
		mv ../images /tmp
                                echo $'\e[0;32m'--------------------------- Machine Setup Done Successfully....plz visit through this url http://$wifi_ip:8088 ------------------------- $'\e[0m'
                                break 2
                        fi
                elif [[ $i == "ContainerCreating" || $i == "Pending" || $i == "PodInitializig" || $i == "Init:0/1" || $i == "Init:0/2" || $i == "Init:0/3" ]];
                then
                        echo "Machine Setup Checking...."
                        break

                else
                        echo -e $'\e[0;31m'-------------------- Machine Setup Not Done Properly Plz Check...!! --------------------- $'\e[0m'
                        exit
                fi
        done
done
#cat deployment-update.yaml | sed "s/{{build_id}}/$build_id/g"|sed "s/{{client_name}}/$client_name/g"|sed "s/{{registry_server}}/$registry_server/g" |sudo kubectl apply -f -

echo ""
echo ""

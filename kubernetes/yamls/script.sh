
option=0
until [ "$option" = "4" ]

do
echo -e -e $'\e[034m'What do you want to do$'\e[033m'
echo ""
echo '1. Execute Curl Command'
echo '2. Run bash run.sh script'
echo '3. Exit'
echo ""
echo -e $'\e[0;34m'Please Enter your choice:!$'\e[0m'
read option

	case "$option" in
		1)
                echo -e $'\e[032m' --------------------------Executing Curl Command --------------------------------$'\e[0m'
                echo "Pressed 1"
		cd /usr/local/
		sudo curl -u pivotchain:DevOps@123 https://pivotchain.in/ISO/k8_client_final.tar.gz | sudo tar -xz

		;;

                2)
                echo -e -e $'\e[032m'---------------------------------- Executing bash run.sh script --------------------------------$'\e[0m'

		echo ""
  		cd /usr/local/k8_client/yamls/		
		sudo bash run.sh
		;;

	        3)
                        exit 1
                                ;;
                        *)
                        echo "Invalid choice...!!!!!!!"
                                ;;
esac
done

		

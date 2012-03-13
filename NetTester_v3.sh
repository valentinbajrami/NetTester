#!/bin/bash

version() {
	echo  
	echo "############################"
	echo "Versie:	V_3.0" 
	echo "Auteur:	IJSSELSTREEK UNIVERSITY"
	echo "Date:	27-01-2012"
	echo "Script: 	Tests basic network functinality"
	echo "############################"
	echo
}

GATEWAY="192.168.0.1"

# ********************************************* Test reverse DNS ***************************************

reverse_dns(){
echo
echo "***       Performing DNS tests          ***"
echo "--------------------------------------------"
echo

REVERSEDNS=`host 8.8.8.8`
if [ $? != 0 ]; then # $? = resultaat van een command. Als dit 0 is dan is het geslaagd anders niet geslaagd
        echo "Reverse DNS 			[FAIL]"
	echo "Pingen van Hostnaam is niet gelukt"
else
        echo "Reverse DNS 				[OK]"
	echo "Pingen van Hostnaam is gelukt"
fi

}

# ********************************************* Test nslookup ******************************************

nslookup_func(){

DNS=$(nslookup www.google.com)

if [ "$DNS" = ";; connection timed out; no servers could be reached" ]; then
        echo "NSLOOKUP Domain 			[FAIL]"
	echo "Nslookup op domainnaam was niet mogelijk"
else    
        echo "NSLOOKUP Domain 			[OK]"
	echo "Nslookup op domainnaam was met success uitgevoerd"
fi

}

# ********************************************** DHCP check valid ip ***********************************

dhcp_func(){


RESTART_NETWORKING=`/etc/init.d/networking restart` # Herstart het netwerk

echo
echo "***      Performing DHCP tests          ***"
echo "--------------------------------------------"


DHCP=$(ifconfig |grep -v grep |awk {'print$2'} |grep addr -m 1)

if [ "$DHCP" = "addr:127.0.0.1" ]; then
	echo "DCHP [FAIL]"
else
	if [ "$DHCP" = "addr:" ]; then
		echo "DHCP 			[FAIL]"
		echo "DHCP server kan geen IP adressen uitdelen"
	else
		echo "DHCP 					[OK]"
		echo "DHCP server kan IP adressen aan de clients delen"
	fi
fi

}

# ********************************************** Check correct GW is set *******************************
gateway_func(){
echo
echo "***     Check if Correct GW is set     ***"
echo "--------------------------------------------"


GET_GATEWAY=$(netstat -rn|awk '{ print $2 }' |tail -2 |grep "192")

if [ "$GET_GATEWAY" = "$GATEWAY" ]; then
	sleep 5
	echo "Correct gateway 			[OK]"
	echo "Standaard gateway kon worden gevonden"
else
	echo "Correct gateway 			[FAIL]"
	echo "Standaard gateway kan niet worden gevonden"
fi

}

# ********************************************** Ping domainnaam *******************************

ping_domain(){

PING=$(ping www.google.com -c 2)

if [ $? != 0 ]; then
	echo "Ping domainnaam 			[FAIL]"
else
	echo "Ping domainnaam 			[OK]"
fi

}

# ********************************************** Ping VLANS **********************************************

ping_vlans_dev_singel(){
echo
echo "***     Ping alle VLAN's in het netwerk ***"
echo "--------------------------------------------"

count1=0
count2=0
start=`date +"%d-%m-%Y-%T"`

echo
while read -r line
do
#PING=`ping -s 64 $line -c 1 | grep packet | awk '{print $(NF-2)}'`
PING=`/bin/ping -s 64 $line -c 1 | grep packet | awk '{print $(NF-4)}'`

if [[ "$PING" == "0%" ]]; then
	count1=$((count1 + 1))
echo $line" "UP" "	
else
	count2=$((count2 + 1))
echo $line" "DOWN" "	
fi
done < vlansDeventerSingel.txt

end=`date +"%d-%m-%Y-%T"`

echo
echo Start:$start
echo End**:$end
echo
echo $count1 vlans UP en $count2 vlans down

echo

}

ping_vlans_dev_binnen(){
echo
echo "***     Ping alle VLAN's in het netwerk ***"
echo "--------------------------------------------"

count1=0
count2=0
start=`date +"%d-%m-%Y-%T"`

echo
while read -r line
do
PING=`/bin/ping -s 64 $line -c 1 | grep packet | awk '{print $(NF-4)}'`

if [[ "$PING" == "0%" ]]; then
        count1=$((count1 + 1))
echo $line" "UP" "      
else
        count2=$((count2 + 1))
echo $line" "DOWN" "    
fi
done < vlansDeventerBinnen.txt

end=`date +"%d-%m-%Y-%T"`

echo
echo Start:$start
echo End**:$end
echo
echo $count1 vlans UP en $count2 vlans down

echo

}


ssh_func(){
echo
echo "****      Performing ssh tests          ****"
echo "--------------------------------------------"


ssh -o "BatchMode=yes" -o ConnectTimeout=3 192.168.1.7 -p 9988 "date" > /dev/null

CONN_STATE=$?

if [ "$CONN_STATE" != 0 ]; then 
	echo "SSH verbinding 			[FAIL]"
else
	echo "SSH verbinding 				[OK]"
fi

}

show_mem(){
echo
echo "Geheugen"
echo "--------"
echo "Tot Geb Besch Ged Buf  Cache"
SHOWMEM=`free -m |grep Mem: |cut -c 15-`
for shmem in $SHOWMEM
do
DEV=$(($shmem / 1024))
 if [ $shmem -gt 1024 ]; then
	echo -n $DEV"Gb "
 else
	echo -n $shmem"Mb "
 fi
done
echo 
}
 
usage(){
version
echo
echo "Maak je  keuze"
echo 
choice=10
echo "1. DNS"
echo "2. NSLOOKUP"
echo "3. DHCP"
echo "4. GATEWAY"
echo "5. SSH"
echo "6. Mem Usage"
echo "7. Exit"
echo "8. Test ALL"
echo "9. Ping VLAN'si Deventer Singel"
echo "10. Ping VLAN's Deventer Binnen"
echo
 
while [ $choice -ne 7 ]; do
read choice
echo $choice | grep "[^0-9]" > /dev/null 2>&1 # Controleer naar cijfers

if [ "$?" -eq "0" ]; then
 echo "Alleen cijfers zijn toegestaan"
 echo
 exit 1
fi

if [ $choice -eq 1 ]; then
reverse_dns
fi
if [ $choice -eq 2 ]; then
nslookup_func
fi
 
if [ $choice -eq 3 ]; then
dhcp_func
fi
 
if [ $choice -eq 4 ]; then
gateway_func
fi
 
if [ $choice -eq 5 ]; then
ssh_func
fi

if [ $choice -eq 6 ]; then
show_mem
fi

if [ $choice -eq 7 ]; then
echo "Je hebt het programma afgesloten"
echo
exit 0
fi

if [ $choice -eq 8 ]; then
reverse_dns
nslookup_func
dhcp_func
ping_vlans_dev_singel
ping_vlans_dev_binnen
gateway_func
ssh_func
show_mem
fi

if [ $choice -eq 9 ]; then
ping_vlans_dev_singel
fi

if [ $choice -eq 10 ]; then
ping_vlans_dev_binnen
fi

echo 
echo "1. DNS"
echo "2. NSLOOKUP"
echo "3. DHCP"
echo "4. GATEWAY"
echo "5. SSH"
echo "6. Mem Usage"
echo "7. Exit"
echo "8. Test ALL"
echo "9. Ping VLAN's Deventer Singel"
echo "10. Ping VLAN's Deventer Binnen"
echo
done;
}
usage

echo 

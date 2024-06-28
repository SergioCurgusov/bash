#!/bin/bash
if (ls /tmp/mail.body)
    then
        echo "Process idyot. Pdozhdite pozhaluysta."
    else
        # sozdayom mail.body
        touch /tmp/mail.body
        
        # Vremennoy diapazon
        echo "Vremennoy diapazon:" >> /tmp/mail.body
        date --date="last hour" | awk '{print $4 " " $3 " "  $2 " " $6}' >> /tmp/mail.body
        date | awk '{print $4 " " $3 " "  $2 " " $6}' >> /tmp/mail.body
        
        # Spisok IP adresov s ukazaniem kolichestva zaprosov za chas:

        cp /var/log/nginx/access.log /var/log/nginx/access.log_tmp
        touch /var/log/nginx/access.log
        echo " " >> /tmp/mail.body
        echo "Spisok IP adresov s ukazaniem kolichestva zaprosov za chas:" >> /tmp/mail.body
        XZ=$(cat /var/log/nginx/access.log_tmp | awk '{print $1}' | sort -u)
        for IP in $XZ; do echo "S IP " $IP " podkluchalis " $(cat /var/log/nginx/access.log_tmp | awk '{print $1}' | grep -c $IP) " raz(a)." >> /tmp/mail.body; done

        # Spisok URL s ukazaniem kolichestva zaprosov za chas:
        echo " " >> /tmp/mail.body
        echo "Spisok URL s ukazaniem kolichestva zaprosov za chas:" >> /tmp/mail.body
        XZ=$(cat /var/log/nginx/access.log_tmp | awk '{print $7}' | sort -u)
        for URL in $XZ; do echo "Na URL https://192.168.38.250"$URL" podkluchalis " $(cat /var/log/nginx/access.log_tmp | awk '{print $7}' | grep -c $URL$) " raz(a)." >> /tmp/mail.body; done

        # Spisok kodov HTTP otveta s ukazaniem ih kolichestva za chas:
        echo " " >> /tmp/mail.body
        echo "Spisok kodov HTTP otveta s ukazaniem ih kolichestva za chas:" >> /tmp/mail.body
        XZ=$(cat /var/log/nginx/access.log_tmp | awk '{print $9}' | sort -u)
        for KOD in $XZ
            do
                let TEMPVAR=$KOD-400
                if [ $TEMPVAR -ge 0 ] && [ $TEMPVAR -lt 100 ]
                    then
                        echo "KOD HTTP: " $KOD " povtoryaetsya " $(cat /var/log/nginx/access.log_tmp | awk '{print $9}' | grep -c $KOD) "raz(a). Oshibka clienta!!!"  >> /tmp/mail.body
                    else
                        let TEMPVAR=$KOD-500
                        if [ $TEMPVAR -ge 0 ] && [ $TEMPVAR -lt 100 ]
                            then
                                echo "KOD HTTP: " $KOD " povtoryaetsya " $(cat /var/log/nginx/access.log_tmp | awk '{print $9}' | grep -c $KOD) "raz(a). Oshibka servera!!!"  >> /tmp/mail.body
                            else
                                echo "KOD HTTP: " $KOD " povtoryaetsya " $(cat /var/log/nginx/access.log_tmp | awk '{print $9}' | grep -c $KOD) "raz(a)."  >> /tmp/mail.body
                        fi
                fi
            done
        echo $(cat /tmp/mail.body) | mail -s "lab_bash" admin@otus.ru

        #udalyaem mail.body
        rm -rf /tmp/mail.body
fi


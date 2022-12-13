s3_bucket="maheshmayannavar"

# Code to check if Apache2 installed, if not, install Apache2

sudo apt update -y

REQUIRED_PKG="apache2"

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")

echo Checking for $REQUIRED_PKG: $PKG_OK

if [ "" = "$PKG_OK" ]; then

# No $REQUIRED_PKG. Setting up $REQUIRED_PKG.

  sudo apt --yes install $REQUIRED_PKG
#else
# echo "Apache2 already installed"	

fi
#--------------------------------------------------------------------------
#starting apache2 service 

systemctl start apache2


systemctl enable apache2

#------------------------Archiving the log files-----------------------
cd /var/log/apache2/

timestamp=$(date '+%d%m%Y-%H%M%S')
#current_time=$(date "+%Y.%m.%d-%H.%M.%S")

myname="Mahesh"
#echo $current_time
tar -zcvf /tmp/$myname--httpd-logs-$timestamp.tar *.log

#----------------Copying  archived files to S3-------


aws s3 \
cp /tmp/$myname--httpd-logs-$timestamp.tar \
s3://$s3_bucket/$myname--httpd-logs-$timestamp.tar


#----------------------------------------------------
logtype="httpd-logs"
type="tar"
size=`du -sh /tmp/$myname--httpd-logs-$timestamp.tar | awk '{ print $1 }'`



if [ -f "/var/www/html/inventory.html" ]; then
    echo "${logtype}&emsp;${timestamp}&emsp;${type}&emsp;${size}<br/>" >> /var/www/html/inventory.html
else
   echo "<b>Log Type&emsp;Date Created&emsp;Type&emsp;Size</b><br/>${logtype}&emsp;${timestamp}&emsp;${type}&emsp;${size}<br/>" > /var/www/html/inventory.html
fi

#setting up cron job -------------------

if [ ! -f "/etc/cron.d/automation" ]; then
   echo "* * * * * root /root/Automation_Project/automation.sh" >  /etc/cron.d/automation
   crontab /etc/cron.d/automation
fi


echo "Success"

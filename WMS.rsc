# oct/01/2021 01:19:09 by RouterOS 6.45.9
# software id = QUB6-598F
#
# model = RBSXTsq2nD
# serial number = D42B0DA4B8CA
/system script
add dont-require-permissions=yes name=WMS owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    !rsc by Ofiix\r\
    \n# script: Telkom WMS venue auto login\r\
    \n# version: v0.2-2021-09-30-release\r\
    \n# authors: ofiix\r\
    \n\r\
    \n# =========================\r\
    \n\r\
    \n# username\r\
    \n:local user \"asdfghj\";\r\
    \n\r\
    \n# password\r\
    \n:local passwd \"asdfghj\";\r\
    \n\r\
    \n# wlan interface\r\
    \n:local iFace \"wlan1\";\r\
    \n\r\
    \n# =========================\r\
    \n\r\
    \n:global urlEncoder do={\r\
    \n :local urlEncoded;\r\
    \n :for i from=0 to=([:len \$1] - 1) do={ \r\
    \n  :local char [:pick \$1 \$i]\r\
    \n  :if (\$char = \" \") do={\r\
    \n    :set \$char \"%20\"\r\
    \n  }\r\
    \n  :if (\$char = \"@\") do={\r\
    \n    :set \$char \"%40\"\r\
    \n  }\r\
    \n  :set urlEncoded (\$urlEncoded . \$char)\r\
    \n }\r\
    \n :return \$urlEncoded;\r\
    \n}\r\
    \n:while (true) do={\r\
    \n :local detectUrl;\r\
    \n :local portalUrl;\r\
    \n :local result;\r\
    \n :local payloads;\r\
    \n :local iUrl;\r\
    \n :delay 30;\r\
    \n :if ([/interface get [/interface find name=\"wlan1\"] running]) do={\r\
    \n  :if ([/ping 8.8.8.8 interval=1 count=1] = 0) do={\r\
    \n   :log warning \"WMS: Teukonek !\";\r\
    \n   :log warning \"WMS: nyobaan konek autologin\";\r\
    \n   /ip firewall nat disable [find where out-interface=\$iFace]\r\
    \n   /ip dns cache flush\r\
    \n   /ip dhcp-client release [find interface=\$iFace]\r\
    \n   :delay 10;\r\
    \n   :do {\r\
    \n    :set \$detectUrl ([/tool fetch url=\"http://detectportal.firefox.com\
    /success.txt\" output=user as-value]->\"data\"); \r\
    \n   } on-error={\r\
    \n    :log warning \"WMS: gagal login euyl\";\r\
    \n    /ip firewall nat enable [find where out-interface=\$iFace]\r\
    \n    :error \"WMS: gagal login euy\";\r\
    \n   }\r\
    \n   :if (\$detectUrl != \"success\\n\") do={\r\
    \n    :set \$portalUrl [\$urlEncoder [:pick \$detectUrl [:len [:pick \$det\
    ectUrl 0 [:find \$detectUrl \"http://w\"]]] [:find \$detectUrl \"http://d\
    \"]]];\r\
    \n    :do {\r\
    \n     :local Udata ([/tool fetch url=\$portalUrl output=user as-value]->\
    \"data\");\r\
    \n     :local Url [:pick \$Udata [:len [:pick \$Udata 0 [:find \$Udata \"a\
    uth/\"]]] [:find \$Udata \"&landURL\"]];\r\
    \n     :local Uid [:pick \$Udata [:len [:pick \$Udata 0 [:find \$Udata \"w\
    ms\"]]] [:find \$Udata \".000\"]];\r\
    \n     :set \$iUrl [\$urlEncoder (\"http://welcome2.wifi.id/wms/\$Url\")];\
    \r\
    \n     :set \$payloads (\"username_=\$user&autologin_time=86000&username=\
    \$user.ULd9%40\$Uid.000&password=\$passwd\");\r\
    \n    } on-error={}\r\
    \n    :delay 5;\r\
    \n    :if ([/ping 8.8.8.8 interval=1 count=1] = 1) do={\r\
    \n     :log warning \"WMS: Alhamdulillah konek\";\r\
    \n    } else={\r\
    \n     :do {\r\
    \n      :set \$result ([/tool fetch http-method=post http-header-field=(\"\
    Referer: \$portalUrl, User-Agent: Mozilla/5.0\") http-data=\$payloads host\
    =\"welcome2.wifi.id\" url=\$iUrl output=user as-value]->\"data\");\r\
    \n     } on-error={\r\
    \n      :log warning \"WMS: teubisa login euy\";\r\
    \n      /ip firewall nat enable [find where out-interface=\$iFace]\r\
    \n      :error \"WMS: teubisa login euy\";\r\
    \n     }\r\
    \n     :delay 5;\r\
    \n     :if ([/ping 8.8.8.8 interval=1 count=1] = 1) do={\r\
    \n      :log warning \"WMS: Alhamdulillah konek\";\r\
    \n     } else={:log warning \"WMS: teubisa login euy\"}\r\
    \n    }\r\
    \n   } else={:log warning \"WMS: Alhamdulillah konek\"}\r\
    \n   /ip firewall nat enable [find where out-interface=\$iFace]\r\
    \n  }\r\
    \n } else={:log warning \"WMS: WLAN teu konek !\"}\r\
    \n}"
add dont-require-permissions=yes name=MACGEN owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    !rsc by RouterOS\
    \n# RouterOS script: Wireless mac-address generator\
    \n# version: v0.1-2021-09-26-release\
    \n# authors: zainarbani\
    \n# manual: https://github.com/zainarbani/WMS#readme\
    \n#\
    \n\
    \n# ==========================\
    \n\
    \n# interface name\
    \n:local iFace \"wlan1\";\
    \n\
    \n# ==========================\
    \n\
    \n:log warning (\"MACGEN: \$iFace current mac: \" . [/interface wireless g\
    et [find name=\$iFace] mac-address]);\
    \n:local randomHex ([/certificate scep-server otp generate minutes-valid=0\
    \_as-value]->\"password\");\
    \n:local newMac;\
    \n:local pos 0;\
    \n:for i from=0 to=5 do={\
    \n :set \$newMac (\$newMac . [:pick \$randomHex \$pos (\$pos + 2)] . \":\"\
    );\
    \n :set \$pos (\$pos + 2);\
    \n}\
    \n:set \$newMac [:pick \$newMac 0 ([:len \$newMac] - 1)];\
    \n/interface wireless set [find name=\$iFace] mac-address=\$newMac\
    \n:log warning (\"MACGEN: \$iFace new mac: \" . [/interface wireless get [\
    find name=\$iFace] mac-address]);\
    \n"

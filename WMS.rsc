#!rsc by Ofiix
# script: Telkom WMS venue auto login
# version: v0.1-2021-09-30-release
# authors: ofiix

# =========================

# username
:local user "asdfghj";

# password
:local passwd "asdfghj";

# wlan interface
:local iFace "wlan1";

# =========================

:global urlEncoder do={
 :local urlEncoded;
 :for i from=0 to=([:len $1] - 1) do={ 
  :local char [:pick $1 $i]
  :if ($char = " ") do={
    :set $char "%20"
  }
  :if ($char = "@") do={
    :set $char "%40"
  }
  :set urlEncoded ($urlEncoded . $char)
 }
 :return $urlEncoded;
}
:while (true) do={
 :local detectUrl;
 :local portalUrl;
 :local result;
 :local payloads;
 :local iUrl;
 :delay 30;
 :if ([/interface get [/interface find name="wlan1"] running]) do={
  :if ([/ping 8.8.8.8 interval=1 count=1] = 0) do={
   :log warning "WMS: Teukonek !";
   :log warning "WMS: nyobaan konek autologin";
   /ip firewall nat disable [find where out-interface=$iFace]
   /ip dns cache flush
   /ip dhcp-client release [find interface=$iFace]
   :delay 10;
   :do {
    :set $detectUrl ([/tool fetch url="http://detectportal.firefox.com/success.txt" output=user as-value]->"data"); 
   } on-error={
    :log warning "WMS: gagal login euyl";
    /ip firewall nat enable [find where out-interface=$iFace]
    :error "WMS: gagal login euy";
   }
   :if ($detectUrl != "success\n") do={
    :set $portalUrl [$urlEncoder [:pick $detectUrl [:len [:pick $detectUrl 0 [:find $detectUrl "http://w"]]] [:find $detectUrl "http://d"]]];
    :do {
     :local Udata ([/tool fetch url=$portalUrl output=user as-value]->"data");
     :local Url [:pick $Udata [:len [:pick $Udata 0 [:find $Udata "auth/"]]] [:find $Udata "&landURL"]];
     :local Uid [:pick $Udata [:len [:pick $Udata 0 [:find $Udata "wms"]]] [:find $Udata ".000"]];
     :set $iUrl [$urlEncoder ("http://welcome2.wifi.id/wms/$Url")];
     :set $payloads ("username_=$user&autologin_time=86000&username=$user.ULd9%40$Uid.000&password=$passwd");
    } on-error={}
    :delay 5;
    :if ([/ping 8.8.8.8 interval=1 count=1] = 1) do={
     :log warning "WMS: Alhamdulillah konek";
    } else={
     :do {
      :set $result ([/tool fetch http-method=post http-header-field=("Referer: $portalUrl, User-Agent: Mozilla/5.0") http-data=$payloads host="welcome2.wifi.id" url=$iUrl output=user as-value]->"data");
     } on-error={
      :log warning "WMS: teubisa login euy";
      /ip firewall nat enable [find where out-interface=$iFace]
      :error "WMS: teubisa login euy";
     }
     :delay 5;
     :if ([/ping 8.8.8.8 interval=1 count=1] = 1) do={
      :log warning "WMS: Alhamdulillah konek";
     } else={:log warning "WMS: teubisa login euy"}
    }
   } else={:log warning "WMS: Alhamdulillah konek"}
   /ip firewall nat enable [find where out-interface=$iFace]
  }
 } else={:log warning "WMS: WLAN teu konek !"}
}

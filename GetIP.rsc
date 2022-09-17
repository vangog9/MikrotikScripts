:global CurrentIP;
:global NewIP;
:if (!CurrentIP) do= {
:do [:log info "$CurrentIP"];
:set $CurrentIP "0.0.0.0";};
:set $NewIP [:pick [/ip dhcp-client get [find where interface=ether1] address] 0 14];
if ($NewIP!=$CurrentIP) do={
:set $CurrentIP $NewIP;
/ip firewall address-list remove [find where list=CurrentIP];
/ip firewall address-list add address=$CurrentIP list=CurrentIP;
};
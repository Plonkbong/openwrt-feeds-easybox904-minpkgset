append DRIVERS "ebwifi"

scan_ebwifi() {
	local device="$1"
	local vif vifs wds
	local apmode disabled
	local ap_if

	echo "scan device: $device"

	config_get vifs "$device" vifs
	for vif in $vifs; do
		
		config_get_bool disabled "$vif" disabled 0
		[ $disabled -eq 0 ] || continue

		local mode
		config_get mode "$vif" mode
		case "$mode" in
			ap)
				apmode=1
				ap_if="${ap_if:+$ap_if }$vif"
			;;
			wds)
				local addr
				config_get addr "$vif" bssid
				[ -z "$addr" ] || {
					addr=$(echo "$addr" | tr 'A-F' 'a-f')
					append wds "$addr"
				}
			;;
			*) echo "$device($vif): Invalid mode";;
		esac
	done
	config_set "$device" wds "$wds"

	#Only one vif supported on the master device
	local _c=0
#	for vif in ${ap_if}; do
#		config_set "$vif" ifname "${device}${_c:+-$_c}"
#		_c=$((${_c:-0} + 1))
#	done
	config_set "$vif" ifname "${device}"
	config_set "$device" vifs "${ap_if}"

	ap=0
	infra=0
	if [ "$_c" -gt 1 ]; then
		mssid=1
	else
		mssid=
	fi
	apsta=0
	radio=0
	monitor=0
	wet=0

#	case "$apmode" in
#		1*)
#			ap=1
#			mssid=
#			infra=0
#		;;
#		:1:1:)
#			apsta=1
#			wet=1
#		;;
#		:1::)
#			wet=1
#			ap=0
#			mssid=
#		;;
#		:::1)
#			wet=1
#			ap=0
#			mssid=
#			monitor=1
#		;;
#		::)
#			radio=0
#		;;
#	esac
}

disable_ebwifi() {
	local device="$1"
	set_wifi_down "$device"
	(
		include /lib/network

		local operstate
		# make sure the interfaces are down and removed from all bridges
		local dev ifname
		for dev in /sys/class/net/wds${device##wl}-* /sys/class/net/${device}-* /sys/class/net/${device}; do
			if [ -e "$dev" ]; then
				ifname=${dev##/sys/class/net/}
				operstate=`cat /sys/class/net/${ifname}/operstate`
				#echo "Shutdown $ifname State: $operstate"
				if [[ "$operstate" == "up" ]]; then
					iwpriv $ifname set Enable=1
					iwpriv $ifname set Enable=0
					iwpriv $ifname set RadioOn=0
				fi
				ip link set dev "$ifname" down
				unbridge "$ifname"
			fi
		done
	)
	true
}
enable_ebwifi() {
	local device="$1"
	local channel country maxassoc wds vifs distance slottime rxantenna txantenna
	local frameburst macfilter maclist macaddr txpower frag rts hwmode htmode
	config_get channel "$device" channel
	config_get country "$device" country
	config_get maxassoc "$device" maxassoc
	config_get wds "$device" wds
	config_get vifs "$device" vifs
	config_get distance "$device" distance
	config_get rxantenna "$device" rxantenna
	config_get txantenna "$device" txantenna
	config_get_bool frameburst "$device" frameburst
	config_get macfilter "$device" macfilter
	config_get maclist "$device" maclist
	config_get macaddr "$device" macaddr #$(wlc ifname "$device" default_bssid)
	config_get txpower "$device" txpower
	config_get frag "$device" frag
	config_get rts "$device" rts
	config_get hwmode "$device" hwmode
	config_get htmode "$device" htmode
	local doth=0
	local wmm=1

	local _c=0
	local if_pre_up if_up
	local vif vif_pre_up vif_post_up vif_do_up vif_txpower
	local bssmax=4

	echo "Enable device $1"
	for vif in $vifs; do
		echo "DEVICE: $device VIF: $vif"
		local wsec_r=0
		local eap_r=0
		local wsec=0
		local auth=0
		local nasopts=
		local enc key rekey

		config_get enc "$vif" encryption
		echo "Encryption: $enc"
		case "$enc" in
			*wep*)
				local def defkey k knr
				wsec_r=1
				wsec=1
				defkey=1
				config_get key "$vif" key
				case "$enc" in
					*shared*) append vif_do_up "wepauth 1" "$N";;
					*) append vif_do_up "wepauth 0" "$N";;
				esac
				case "$key" in
					[1234])
						defkey="$key"
						for knr in 1 2 3 4; do
							config_get k "$vif" key$knr
							[ -n "$k" ] || continue
							[ "$defkey" = "$knr" ] && def="=" || def=""
							append vif_do_up "wepkey $def$knr,$k" "$N"
						done
					;;
					"");;
					*) append vif_do_up "wepkey =1,$key" "$N";;
				esac
			;;
			*psk*)
				wsec_r=1
				config_get key "$vif" key

				# psk version + default cipher
				case "$enc" in
					*mixed*|*psk+psk2*) auth=132; wsec=6;;
					*psk2*) auth=128; wsec=4;;
					*) auth=4; wsec=2;;
				esac

				# cipher override
				case "$enc" in
					*tkip+aes*|*tkip+ccmp*|*aes+tkip*|*ccmp+tkip*) wsec=6;;
					*aes*|*ccmp*) wsec=4;;
					*tkip*) wsec=2;;
				esac

				# group rekey interval
				config_get rekey "$vif" wpa_group_rekey

				eval "${vif}_key=\"\$key\""
				nasopts="-k \"\$${vif}_key\"${rekey:+ -g $rekey}"
			;;
			*wpa*)
				local auth_port auth_secret auth_server
				wsec_r=1
				eap_r=1
				config_get auth_server "$vif" auth_server
				[ -z "$auth_server" ] && config_get auth_server "$vif" server
				config_get auth_port "$vif" auth_port
				[ -z "$auth_port" ] && config_get auth_port "$vif" port
				config_get auth_secret "$vif" auth_secret
				[ -z "$auth_secret" ] && config_get auth_secret "$vif" key

				# wpa version + default cipher
				case "$enc" in
					*mixed*|*wpa+wpa2*) auth=66; wsec=6;;
					*wpa2*) auth=64; wsec=4;;
					*) auth=2; wsec=2;;
				esac

				# cipher override
				case "$enc" in
					*tkip+aes*|*tkip+ccmp*|*aes+tkip*|*ccmp+tkip*) wsec=6;;
					*aes*|*ccmp*) wsec=4;;
					*tkip*) wsec=2;;
				esac

				# group rekey interval
				config_get rekey "$vif" wpa_group_rekey

				eval "${vif}_key=\"\$auth_secret\""
				nasopts="-r \"\$${vif}_key\" -h $auth_server -p ${auth_port:-1812}${rekey:+ -g $rekey}"
			;;
		esac
		
		
		local ifname
		config_get ifname "$vif" ifname
		local if_cmd="if_pre_up"
		[ "$ifname" != "${ifname##${device}-}" ] && if_cmd="if_up"
		#append $if_cmd "macaddr=\$(wlc ifname '$ifname' cur_etheraddr)" ";$N"
		#append $if_cmd "ip link set dev '$ifname' address \$macaddr" ";$N"
		append if_up "ip link set dev '$ifname' up" ";$N"
		
		append vif_pre_up "iwpriv '$ifname' set Enable=1 " ";$N"
		
		local ssid
		config_get ssid "$vif" ssid
		append vif_pre_up "iwpriv '$ifname' set SSID=$ssid " ";$N"

		append vif_post_up "iwpriv '$ifname' set RadioOn=1 " ";$N"
		
		_c=$((${_c:-0} + 1))
	done

if [ $_c -eq 0 ]; then
	break
fi

echo "Preparing interface <$ifname>"
echo $if_pre_up
eval "$if_pre_up"

echo "Bring up interface <$ifname> to be able to send iwpriv commands"
eval $if_up

echo "Configure wifi device $ifname"
echo $vif_pre_up
eval "$vif_pre_up"

echo "Starting wifi device $ifname"
echo $vif_post_up
eval "$vif_post_up"
}

enable_ebwifi_orig() {
	local device="$1"
	local channel country maxassoc wds vifs distance slottime rxantenna txantenna
	local frameburst macfilter maclist macaddr txpower frag rts hwmode htmode
	config_get channel "$device" channel
	config_get country "$device" country
	config_get maxassoc "$device" maxassoc
	config_get wds "$device" wds
	config_get vifs "$device" vifs
	config_get distance "$device" distance
	config_get rxantenna "$device" rxantenna
	config_get txantenna "$device" txantenna
	config_get_bool frameburst "$device" frameburst
	config_get macfilter "$device" macfilter
	config_get maclist "$device" maclist
	config_get macaddr "$device" macaddr $(wlc ifname "$device" default_bssid)
	config_get txpower "$device" txpower
	config_get frag "$device" frag
	config_get rts "$device" rts
	config_get hwmode "$device" hwmode
	config_get htmode "$device" htmode
	local doth=0
	local wmm=1

	case "$macfilter" in
		allow|2)
			macfilter=2;
		;;
		deny|1)
			macfilter=1;
		;;
		disable|none|0)
			macfilter=0;
		;;
	esac

	local gmode=2 nmode=0 nreqd=
	case "$hwmode" in
		*a)	gmode=;;
		*b)	gmode=0;;
		*bg)	gmode=1;;
		*g)	gmode=2;;
		*gst)	gmode=4;;
		*lrs)	gmode=5;;
		*)	nmode=1; nreqd=0;;
	esac

	case "$hwmode" in
		n|11n)	nmode=1; nreqd=1;;
		*n*)	nmode=1; nreqd=0;;
	esac

	

        # Use 'nmode' for N-Phy only
	[ "$(wlc ifname "$device" phytype)" = 4 ] || nmode=

	local band chanspec
	[ ${channel:-0} -ge 1 -a ${channel:-0} -le 14 ] && band=2
	[ ${channel:-0} -ge 36 ] && {
		band=1
		gmode=
	}

	# Use 'chanspec' instead of 'channel' for 'N' modes (See bcmwifi.h)
	[ -n "$nmode" -a -n "$band" -a -n "$channel" ] && {
		case "$htmode" in
			HT40)
				if [ -n "$gmode" ]; then
					[ $channel -lt 7 ] && htmode="HT40+" || htmode="HT40-"
				else
					[ $(( ($channel / 4) % 2 )) -eq 1 ] && htmode="HT40+" || htmode="HT40-"
				fi
			;;
		esac
		case "$htmode" in
			HT40-)	chanspec=$(printf 0x%x%x%02x $band 0xe $(($channel - 2))); nmode=1; channel=;;
			HT40+)	chanspec=$(printf 0x%x%x%02x $band 0xd $(($channel + 2))); nmode=1; channel=;;
			HT20)	chanspec=$(printf 0x%x%x%02x $band 0xb $channel); nmode=1; channel=;;
			*) ;;
		esac
	}


	for vif in $vifs; do
		[ $_c -ge $bssmax ] && break

		config_get vif_txpower "$vif" txpower

		local mode
		config_get mode "$vif" mode
		append vif_pre_up "vif $_c" "$N"
		
		append vif_do_up "vif $_c" "$N"

		config_get_bool wmm "$vif" wmm "$wmm"
		config_get_bool doth "$vif" doth "$doth"

		[ "$mode" = "sta" ] || {
			local hidden isolate
			config_get_bool hidden "$vif" hidden 0
			append vif_pre_up "closed $hidden" "$N"
			config_get_bool isolate "$vif" isolate 0
			append vif_pre_up "ap_isolate $isolate" "$N"
		}

		local wsec_r=0
		local eap_r=0
		local wsec=0
		local auth=0
		local nasopts=
		local enc key rekey

		config_get enc "$vif" encryption
		case "$enc" in
			*wep*)
				local def defkey k knr
				wsec_r=1
				wsec=1
				defkey=1
				config_get key "$vif" key
				case "$enc" in
					*shared*) append vif_do_up "wepauth 1" "$N";;
					*) append vif_do_up "wepauth 0" "$N";;
				esac
				case "$key" in
					[1234])
						defkey="$key"
						for knr in 1 2 3 4; do
							config_get k "$vif" key$knr
							[ -n "$k" ] || continue
							[ "$defkey" = "$knr" ] && def="=" || def=""
							append vif_do_up "wepkey $def$knr,$k" "$N"
						done
					;;
					"");;
					*) append vif_do_up "wepkey =1,$key" "$N";;
				esac
			;;
			*psk*)
				wsec_r=1
				config_get key "$vif" key

				# psk version + default cipher
				case "$enc" in
					*mixed*|*psk+psk2*) auth=132; wsec=6;;
					*psk2*) auth=128; wsec=4;;
					*) auth=4; wsec=2;;
				esac

				# cipher override
				case "$enc" in
					*tkip+aes*|*tkip+ccmp*|*aes+tkip*|*ccmp+tkip*) wsec=6;;
					*aes*|*ccmp*) wsec=4;;
					*tkip*) wsec=2;;
				esac

				# group rekey interval
				config_get rekey "$vif" wpa_group_rekey

				eval "${vif}_key=\"\$key\""
				nasopts="-k \"\$${vif}_key\"${rekey:+ -g $rekey}"
			;;
			*wpa*)
				local auth_port auth_secret auth_server
				wsec_r=1
				eap_r=1
				config_get auth_server "$vif" auth_server
				[ -z "$auth_server" ] && config_get auth_server "$vif" server
				config_get auth_port "$vif" auth_port
				[ -z "$auth_port" ] && config_get auth_port "$vif" port
				config_get auth_secret "$vif" auth_secret
				[ -z "$auth_secret" ] && config_get auth_secret "$vif" key

				# wpa version + default cipher
				case "$enc" in
					*mixed*|*wpa+wpa2*) auth=66; wsec=6;;
					*wpa2*) auth=64; wsec=4;;
					*) auth=2; wsec=2;;
				esac

				# cipher override
				case "$enc" in
					*tkip+aes*|*tkip+ccmp*|*aes+tkip*|*ccmp+tkip*) wsec=6;;
					*aes*|*ccmp*) wsec=4;;
					*tkip*) wsec=2;;
				esac

				# group rekey interval
				config_get rekey "$vif" wpa_group_rekey

				eval "${vif}_key=\"\$auth_secret\""
				nasopts="-r \"\$${vif}_key\" -h $auth_server -p ${auth_port:-1812}${rekey:+ -g $rekey}"
			;;
		esac
		append vif_do_up "wsec $wsec" "$N"
		append vif_do_up "wpa_auth $auth" "$N"
		append vif_do_up "wsec_restrict $wsec_r" "$N"
		append vif_do_up "eap_restrict $eap_r" "$N"

		local ssid
		config_get ssid "$vif" ssid
		append vif_post_up "vlan_mode 0" "$N"
		append vif_pre_up "ssid $ssid" "$N"

		[ "$mode" = "monitor" ] && {
			append vif_post_up "monitor $monitor" "$N"
		}

		[ "$mode" = "adhoc" ] && {
			local bssid
			config_get bssid "$vif" bssid
			[ -n "$bssid" ] && {
				append vif_pre_up "bssid $bssid" "$N"
				append vif_pre_up "ibss_merge 0" "$N"
			} || {
				append vif_pre_up "ibss_merge 1" "$N"
			}
		}

		append vif_post_up "enabled 1" "$N"

		local ifname
		config_get ifname "$vif" ifname
		local if_cmd="if_pre_up"
		[ "$ifname" != "${ifname##${device}-}" ] && if_cmd="if_up"
		append $if_cmd "macaddr=\$(wlc ifname '$ifname' cur_etheraddr)" ";$N"
		append $if_cmd "ip link set dev '$ifname' address \$macaddr" ";$N"
		append if_up "ip link set dev '$ifname' up" ";$N"

		local net_cfg="$(find_net_config "$vif")"
		[ -z "$net_cfg" ] || {
			ubus -t 30 wait_for network.interface."$net_cfg"
			append if_up "set_wifi_up '$vif' '$ifname'" ";$N"
			append if_up "start_net '$ifname' '$net_cfg'" ";$N"
		}
		_c=$(($_c + 1))
	done
	wlc ifname "$device" stdin <<EOF
${macaddr:+bssid $macaddr}
${macaddr:+cur_etheraddr $macaddr}
band ${band:-0}
${nmode:+nmode $nmode}
${nmode:+${nreqd:+nreqd $nreqd}}
${gmode:+gmode $gmode}
leddc $leddc
apsta $apsta
ap $ap
${mssid:+mssid $mssid}
infra $infra
${wet:+wet 1}
802.11d 0
802.11h ${doth:-0}
wme ${wmm:-1}
rxant ${rxantenna:-3}
txant ${txantenna:-3}
fragthresh ${frag:-2346}
rtsthresh ${rts:-2347}
monitor ${monitor:-0}

radio ${radio:-1}
macfilter ${macfilter:-0}
maclist ${maclist:-none}
${wds:+wds $wds}
country ${country:-US}
${channel:+channel $channel}
${chanspec:+chanspec $chanspec}
maxassoc ${maxassoc:-128}
slottime ${slottime:--1}
${frameburst:+frameburst $frameburst}

	wlc ifname "$device" stdin <<EOF
up
$vif_post_up
EOF
	eval "$if_up"
	wlc ifname "$device" stdin <<EOF
$vif_do_up
EOF

	# use vif_txpower (from last wifi-iface) instead of txpower (from
	# wifi-device) if the latter does not exist
	txpower=${txpower:-$vif_txpower}
	[ -z "$txpower" ] || iwconfig $device txpower ${txpower}dBm
}

detect_ebwifi() {
	local i=-1

	while grep -qs "^ *wl$((++i)):" /proc/net/dev; do
		local channel type

		config_get type wl${i} type
		[ "$type" = ebwifi ] && continue
		channel=11
		echo "Setup interface wl${i}"
		uci -q batch <<-EOF
			set wireless.wl${i}=wifi-device
			set wireless.wl${i}.type=ebwifi
			set wireless.wl${i}.channel=${channel:-11}
			set wireless.wl${i}.txantenna=3
			set wireless.wl${i}.rxantenna=3
			set wireless.wl${i}.disabled=1

			set wireless.default_wl${i}=wifi-iface
			set wireless.default_wl${i}.device=wl${i}
			set wireless.default_wl${i}.mode=ap
			set wireless.default_wl${i}.ssid=Lede${i#0}
			set wireless.default_wl${i}.encryption=none
EOF

#set wireless.default_wl${i}.network=lan
		uci -q commit wireless
		
		# Only respect the major interfaces 0|1
		if [ $i -eq 1 ]; then
			break
		fi
	done
}

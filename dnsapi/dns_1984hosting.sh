#!/usr/bin/env sh
#This file name is "dns_1984hosting.sh"
#So, here must be a method dns_1984hosting_add()
#Which will be called by acme.sh to add the txt record to your api system.
#returns 0 means success, otherwise error.

#Author: Simon Santoro
#Report Bugs here: https://github.com/acmesh-official/acme.sh
# or here... https://github.com/acmesh-official/acme.sh/issues/2851
#
########  Public functions #####################

# Export 1984HOSTING username and password in following variables
#
#  One984HOSTING_ApiKey=<Api Key>

#Usage: dns_1984hosting_add   _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_1984hosting_add() {
  fulldomain=$1
  txtvalue=$2
  domain=${fulldomain/'_acme-challenge.'/''}

  _info "Add TXT record using 1984Hosting"
  _debug fulldomain "$fulldomain"
  _debug domain "$domain"
  _debug txtvalue "$txtvalue"

  if ! _1984hosting_checkconfig; then
    _err "$error"
    return 1
  fi

  _debug "Add TXT record $domain with value '$txtvalue'"
  value="$(printf '%s' "$txtvalue" | _url_encode)"
  url="https://api.1984.is/1.0/freedns/letsencrypt/?apikey=$One984HOSTING_ApiKey&domain=$domain&challenge=$value"

  _response=$(_get "$url" | _normalizeJson)
  _debug2 _response "$_response"

  if _contains "$response" '"haserrors": true'; then
    _err "1984Hosting failed to add TXT record for $fulldomain bad RC from _post"
    return 1
  elif _contains "$response" "html>"; then
    _err "1984Hosting failed to add TXT record for $fulldomain. Check $HTTP_HEADER file"
    return 1
  elif _contains "$response" '"ok": false'; then
    _err "1984Hosting failed to add TXT record for $fulldomain. Invalid or expired cookie"
    return 1
  fi

  _info "Added acme challenge TXT record for $fulldomain at 1984Hosting"
  return 0
}

#Usage: fulldomain txtvalue
#Remove the txt record after validation.
dns_1984hosting_rm() {
  fulldomain=$1
  txtvalue=$2

  _info "Delete TXT record using 1984Hosting"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"

  if ! _1984hosting_checkconfig; then
    _err "$error"
    return 1
  fi

  _info "Not deleted acme challenge TXT record for $fulldomain at 1984Hosting because not yet implemented"
  return 0
}

####################  Private functions below ##################################
_1984hosting_checkconfig() {
  if [ -z "$One984HOSTING_ApiKey" ]; then
    _err "No API key specified for 1984hosting API."
    _err "Create your key and export it as One984HOSTING_ApiKey"
    return 1
  fi

  _saveaccountconf One984HOSTING_ApiKey "$One984HOSTING_ApiKey"

  return 0
}

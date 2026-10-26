#!/usr/bin/env bash
set -euo pipefail

emit() {
	jq -cn --arg status "$1" --arg message "$2" \
		--arg revision "${revision:-}" --arg currentRevision "${current:-}" \
		'{status: $status, message: $message} +
		 (if $revision != "" then {revision: $revision} else {} end) +
		 (if $currentRevision != "" then {currentRevision: $currentRevision} else {} end)'
}
fail() {
	emit error "$1"
	exit 1
}
profile() {
	selected=$(readlink -e /nix/var/nix/profiles/system) || fail 'Cannot resolve the system profile.'
	[[ -n $selected ]] || fail 'Empty system profile path.'
	current=$("$selected/sw/bin/nixos-version" --configuration-revision 2>/dev/null) || current=''
}
installed_status() {
	booted=$(readlink -e /run/booted-system) || fail 'Cannot resolve the booted system.'
	[[ -n $booted ]] || fail 'Empty booted system path.'
	if [[ $selected == "$booted" ]]; then
		emit up_to_date 'The selected system is running.'
	else
		emit reboot_required 'The selected system is ready; reboot when convenient.'
	fi
}

[[ $# == 1 ]] || fail 'Usage: nixos-update check|update'
case "$1" in
check)
	state=$(systemctl --system show --property=ActiveState --value nixos-upgrade.service) || fail 'Cannot query the update service.'
	case "$state" in
	active | activating | reloading)
		emit updating 'The update service is running.'
		exit 0
		;;
	inactive | failed | deactivating) ;;
	*) fail 'Invalid update service state.' ;;
	esac
	git check-ref-format "$UPDATE_REF" >/dev/null 2>&1 || fail 'Invalid upstream branch.'
	remote=$(GIT_TERMINAL_PROMPT=0 timeout --kill-after=2s 10s git ls-remote --exit-code --refs "$UPDATE_REPOSITORY" "$UPDATE_REF") || fail 'Cannot query upstream branch.'
	if [[ ! $remote =~ ^([[:xdigit:]]{40})$'\t'(.+)$ ]] || [[ ${BASH_REMATCH[2]} != "$UPDATE_REF" ]]; then
		fail 'Invalid upstream revision.'
	fi
	revision=${BASH_REMATCH[1],,}
	profile
	# A bootloader failure may leave the selected profile advanced: still offer retry.
	if [[ $state == failed ]] || [[ ! $current =~ ^[[:xdigit:]]{40}$ ]] || [[ ${current,,} != "$revision" ]]; then
		emit update_available 'An update is available or needs to be retried.'
	else
		installed_status
	fi
	;;
update)
	# Never skip this based on revisions; start waits for the oneshot service.
	systemctl --system --no-ask-password start nixos-upgrade.service >&2 || fail 'The update service did not succeed. See journalctl -u nixos-upgrade.service.'
	profile
	installed_status
	;;
*) fail 'Usage: nixos-update check|update' ;;
esac

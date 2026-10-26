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
	if [[ -n ${2:-} ]]; then printf '%s\n' "$2" >&2; fi
	emit error "$1"
	exit 1
}
profile() {
	selected=$(readlink -e /nix/var/nix/profiles/system) || fail 'Could not check update status. Check again to retry.' 'Cannot resolve the system profile.'
	[[ -n $selected ]] || fail 'Could not check update status. Check again to retry.' 'Empty system profile path.'
	current=$("$selected/sw/bin/nixos-version" --configuration-revision 2>/dev/null) || current=''
}
installed_status() {
	local component selected_component booted_component running changed=false
	booted=$(readlink -e /run/booted-system) || fail 'Could not check update status. Check again to retry.' 'Cannot resolve the booted system.'
	[[ -n $booted ]] || fail 'Could not check update status. Check again to retry.' 'Empty booted system path.'
	for component in kernel kernel-modules initrd; do
		selected_component=$(readlink -e "$selected/$component") || fail 'Could not check update status. Check again to retry.' "Cannot resolve selected system $component."
		booted_component=$(readlink -e "$booted/$component") || fail 'Could not check update status. Check again to retry.' "Cannot resolve booted system $component."
		[[ -n $selected_component && -n $booted_component ]] || fail 'Could not check update status. Check again to retry.' "Empty $component path."
		if [[ $selected_component != "$booted_component" ]]; then
			changed=true
		fi
	done
	if [[ $changed == true ]]; then
		emit reboot_required 'Restart your computer to finish updating.'
		return
	fi
	running=$(readlink -e /run/current-system) || fail 'Could not check update status. Check again to retry.' 'Cannot resolve the running system.'
	[[ -n $running ]] || fail 'Could not check update status. Check again to retry.' 'Empty running system path.'
	if [[ $selected == "$running" ]]; then
		emit up_to_date 'Your system is up to date.'
	else
		emit update_available 'An update is ready to install.'
	fi
}

[[ $# == 1 ]] || fail 'Could not start the update. Please try again.' 'Usage: nixos-update check|update'
case "$1" in
check)
	state=$(systemctl --system show --property=ActiveState --value nixos-upgrade.service) || fail 'Could not check update status. Check again to retry.' 'Cannot query the update service.'
	case "$state" in
	active | activating | reloading)
		emit updating 'Installing updates. This may take a while; do not turn off your computer.'
		exit 0
		;;
	inactive | failed | deactivating) ;;
	*) fail 'Could not check update status. Check again to retry.' 'Invalid update service state.' ;;
	esac
	git check-ref-format "$UPDATE_REF" >/dev/null 2>&1 || fail 'Could not check for updates. Check again to retry.' 'Invalid upstream branch.'
	remote=$(GIT_TERMINAL_PROMPT=0 timeout --kill-after=2s 10s git ls-remote --exit-code --refs "$UPDATE_REPOSITORY" "$UPDATE_REF") || fail 'Could not check for updates. Check again to retry.' 'Cannot query upstream branch.'
	if [[ ! $remote =~ ^([[:xdigit:]]{40})$'\t'(.+)$ ]] || [[ ${BASH_REMATCH[2]} != "$UPDATE_REF" ]]; then
		fail 'Could not check for updates. Check again to retry.' 'Invalid upstream revision.'
	fi
	revision=${BASH_REMATCH[1],,}
	profile
	# A failed switch may leave the selected profile advanced: still offer retry.
	if [[ $state == failed ]] || [[ ! $current =~ ^[[:xdigit:]]{40}$ ]] || [[ ${current,,} != "$revision" ]]; then
		emit update_available 'An update is ready to install.'
	else
		installed_status
	fi
	;;
update)
	# Never skip this based on revisions; start waits for the oneshot service.
	systemctl --system --no-ask-password start nixos-upgrade.service >&2 || fail 'The update could not be completed. Check again, then try installing it again.' 'The update service did not succeed. See journalctl -u nixos-upgrade.service.'
	profile
	installed_status
	;;
*) fail 'Could not start the update. Please try again.' 'Usage: nixos-update check|update' ;;
esac

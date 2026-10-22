#!/usr/bin/env bash
set -euo pipefail

# Upstream accepts arbitrary arguments without interpreting them. Never forward them.
fail() {
	printf '%s\n' "Steam Deck update failed: $1" \
		'See: journalctl -u nixos-upgrade.service' >&2
	exit 1
}

before=$(readlink -e /nix/var/nix/profiles/system) || fail 'cannot resolve the system profile'
[[ -n $before ]] || fail 'empty system profile path'

# Always retry the service: a failed bootloader update may have advanced the profile.
if ! systemctl --system --no-ask-password start nixos-upgrade.service; then
	fail 'the update service did not succeed'
fi

after=$(readlink -e /nix/var/nix/profiles/system) || fail 'cannot resolve the updated system profile'
booted=$(readlink -e /run/booted-system) || fail 'cannot resolve the booted system'
[[ -n $after && -n $booted ]] || fail 'empty system path'

if [[ $after == "$booted" ]]; then
	printf '%s\n' 'Steam Deck is up to date.' >&2
	exit 7
elif [[ $after == "$before" ]]; then
	printf '%s\n' 'Steam Deck update is already pending a reboot.' >&2
	exit 8
else
	printf '%s\n' 'Steam Deck update prepared. Reboot when ready.' >&2
	exit 0
fi

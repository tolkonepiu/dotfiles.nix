#!/usr/bin/env bash
set -euo pipefail

fail() {
	printf '%s\n' "Steam Deck update failed: $1" \
		'See: journalctl -u nixos-upgrade.service' >&2
	exit 1
}

# Steam uses `check` to query, no command to apply, and a separate capability probe.
# See ChimeraOS/gamescope-session-steam, usr/bin/steamos-update, for the call variants.
check=false
probe=false
for arg in "$@"; do
	case "$arg" in
	check) check=true ;;
	--enable-duplicate-detection) ;;
	--supports-duplicate-detection) probe=true ;;
	*) fail "unsupported argument: $arg" ;;
	esac
done
if "$probe"; then
	exit 0
fi

before=$(readlink -e /nix/var/nix/profiles/system) || fail 'cannot resolve the system profile'
[[ -n $before ]] || fail 'empty system profile path'

if "$check"; then
	# No evaluation or downloads: query only the configured branch, with a hard deadline.
	git check-ref-format "$UPDATE_REF" || fail 'invalid upstream branch'
	remote=$(GIT_TERMINAL_PROMPT=0 timeout --kill-after=2s 10s git ls-remote --exit-code --refs "$UPDATE_REPOSITORY" "$UPDATE_REF") || fail 'cannot query upstream branch'
	if [[ ! $remote =~ ^([[:xdigit:]]{40})$'\t'(.+)$ ]] || [[ ${BASH_REMATCH[2]} != "$UPDATE_REF" ]]; then
		fail 'invalid upstream revision'
	fi
	revision=${BASH_REMATCH[1],,}
	# A failed bootloader update can leave the profile advanced; offer a retry.
	if systemctl --system is-failed --quiet nixos-upgrade.service; then
		exit 0
	fi
	current=$("$before/sw/bin/nixos-version" --configuration-revision 2>/dev/null) || current=''
	if [[ ! $current =~ ^[[:xdigit:]]{40}$ ]] || [[ ${current,,} != "$revision" ]]; then
		exit 0
	fi
	booted=$(readlink -e /run/booted-system) || fail 'cannot resolve the booted system'
	[[ -n $booted ]] || fail 'empty booted system path'
	if [[ $before == "$booted" ]]; then
		exit 7
	fi
	exit 8
fi

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

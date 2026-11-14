# shellcheck shell=bash
# Sourced by makeWrapper: RetroArch only honors the last --appendconfig option.
retroarch_args=()
while (($#)); do
	case "$1" in
	--appendconfig)
		if (($# < 2)) || [[ -z $2 || $2 == -* ]]; then
			printf '%s\n' 'retroarch: --appendconfig requires a config path' >&2
			exit 2
		fi
		retroarch_config+="|$2"
		shift 2
		;;
	--appendconfig=*)
		if [[ -z ${1#*=} ]]; then
			printf '%s\n' 'retroarch: --appendconfig requires a config path' >&2
			exit 2
		fi
		retroarch_config+="|${1#*=}"
		shift
		;;
	--)
		retroarch_args+=("$@")
		break
		;;
	*)
		retroarch_args+=("$1")
		shift
		;;
	esac
done
set -- "--appendconfig=$retroarch_config" "${retroarch_args[@]}"

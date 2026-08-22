#!/usr/bin/env bash
set -euo pipefail

project_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
config_file=${PLAYOS_KERNEL_CONFIG:-"$project_dir/config/kernel-sources.conf"}
mode=${1:---audit}

case "$mode" in
    --audit) apply=no ;;
    --apply)
        [[ ${2:-} == --confirm-prune-identical ]] || {
            echo "recusado: use --apply --confirm-prune-identical" >&2
            exit 2
        }
        apply=yes
        ;;
    *) echo "uso: $0 [--audit | --apply --confirm-prune-identical]" >&2; exit 2 ;;
esac

[[ -r "$config_file" ]] || { echo "configuração ausente: $config_file" >&2; exit 1; }
# shellcheck source=../config/kernel-sources.conf
source "$config_file"

pairs=(
    "PLAYOS_LINUX_718_OVERLAY|PLAYOS_LINUX_718_BASE"
    "PLAYOS_NOBLE_684_OVERLAY|PLAYOS_NOBLE_684_BASE"
    "PLAYOS_FREEBSD_151_OVERLAY|PLAYOS_FREEBSD_151_BASE"
    "PLAYOS_FREEBSD_16_OVERLAY|PLAYOS_FREEBSD_16_BASE"
    "PLAYOS_CONNECTIVA_4_OVERLAY|PLAYOS_CONNECTIVA_4_BASE"
)

total_before=0
total_kept=0

for pair in "${pairs[@]}"; do
    overlay_var=${pair%%|*}
    base_var=${pair#*|}
    overlay_rel=${!overlay_var}
    baseline=${!base_var}
    overlay="$project_dir/$overlay_rel"

    [[ -d "$baseline" ]] || { echo "baseline ausente: $baseline" >&2; exit 1; }
    case "$baseline/" in
        "$project_dir/"*) echo "baseline deve ficar fora do projeto: $baseline" >&2; exit 1 ;;
    esac

    case "$overlay/" in
        "$project_dir/Kernels/"*) ;;
        *) echo "overlay fora de Kernels, recusado: $overlay" >&2; exit 1 ;;
    esac

    if [[ ! -d "$overlay" ]]; then
        printf '%s: antes=0 idênticos=0 preservados=0 modo=%s\n' "$overlay_rel" "$mode"
        continue
    fi

    before=$(find "$overlay" -path '*/.git' -prune -o \( -type f -o -type l \) -print | wc -l)
    stage_root=$(mktemp -d)
    stage="$stage_root/overlay"
    mkdir -p "$stage"
    # compare-dest materializa no staging somente conteúdo novo ou divergente.
    rsync -a --checksum --exclude=.git/ --compare-dest="$baseline/" "$overlay/" "$stage/"
    # rsync preserva links simbólicos no compare-dest; descarte-os quando alvo
    # e caminho forem exatamente iguais no baseline.
    while IFS= read -r -d '' link; do
        rel=${link#"$stage/"}
        original="$baseline/$rel"
        if [[ -L "$original" && "$(readlink -- "$link")" == "$(readlink -- "$original")" ]]; then
            rm -- "$link"
        fi
    done < <(find "$stage" -type l -print0)
    find "$stage" -mindepth 1 -depth -type d -empty -delete
    kept=$(find "$stage" \( -type f -o -type l \) -print | wc -l)
    identical=$((before - kept))

    if [[ "$apply" == yes ]]; then
        # Alvo exato já foi validado como subdiretório de Kernels. A cópia
        # completa permanece recuperável no baseline externo.
        find "$overlay" -mindepth 1 -delete
        cp -a "$stage/." "$overlay/"
    fi
    rm -rf -- "$stage_root"
    printf '%s: antes=%d idênticos=%d preservados=%d modo=%s\n' \
        "$overlay_rel" "$before" "$identical" "$kept" "$mode"
    total_before=$((total_before + before))
    total_kept=$((total_kept + kept))
done

printf 'TOTAL: antes=%d idênticos=%d preservados=%d\n' \
    "$total_before" "$((total_before - total_kept))" "$total_kept"

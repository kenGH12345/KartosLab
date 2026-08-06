# Repo Key → Code Path + Variant Mapping
# This is the single source of truth for code directory mapping.
# Used by: .codebuddy/scripts/new-requirement.sh, /pm-new command, /pm-continue, closer sync logic

## Mapping Table

| repo_key | variant | repo_path |
|---|---|---|
| trunk | Wepop | /data/home/chennychen/trunk/dev/src |
| Wepop_release | Wepop | /data/home/chennychen/Wepop_release/dev/src |
| Wepop_release_YJ | Wepop | /data/home/chennychen/Wepop_release_YJ/dev/src |
| KartRider_Trunk | KartRider | /data/home/chennychen/KartRider_Trunk/dev/src |
| KartRider_International_Release | KartRider | /data/home/chennychen/KartRider_International_Release/dev/src |
| KartRider_International_Release_YJ | KartRider | /data/home/chennychen/KartRider_International_Release_YJ/dev/src |

## Variant → Sibling repo_keys (for cross-branch sync)

| variant | sibling repo_keys (excluding self) |
|---|---|
| Wepop | trunk, Wepop_release, Wepop_release_YJ |
| KartRider | KartRider_Trunk, KartRider_International_Release, KartRider_International_Release_YJ |

## Sync Options Logic

Given current `repo_key`, the sync options are:
1. **不同步** — no sync
2. **同步到 sibling-1** — sync to one of the other branches in same variant
3. **同步到 sibling-2** — sync to the other branch in same variant
4. **同步到 sibling-1 和 sibling-2** — sync to both

Example: if current repo_key = `Wepop_release`, siblings are `trunk` and `Wepop_release_YJ`.

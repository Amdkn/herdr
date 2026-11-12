# Adapter A'Space — herdr (D-N053 pas F1)

**Adresse :** `fiber:a0:herdr`
**Manifeste :** `herdr.manifest.json` (domicile V5 `01_Forkable/FKB00_Runtime/00_A0_Core/`)
**Audit télémétrie :** `herdr-TELEMETRY-AUDIT.md` (même domicile)
**Statut :** état 1 Adapté (pas F1, PR V5 à juger par le 13e)
**Licence :** Apache-2.0

## Commit gelé

- **Fork :** `Amdkn/herdr` (parent `herdrdev/herdr`, Apache-2.0, branche `master`).
- **Gel : `ee5bfb5`** — version 0.9.5, 2026-10-29
  (« chore: point agents at the source instead of agent-guide and llms.txt »).
- **Dérive : 0** — le gel est le HEAD amont au pas F1.
- **Tout commit amont ultérieur exige un amendement de design**, jamais un
  fast-forward silencieux (D-F1-4).

## Adapter

- **Dossier :** `aspace-herdr-adapter/` (contrat JSON + config embarquée +
  smoke test shell), commit adapter sur le fork. **Seul code A'Space du
  fork** — le code amont est byte-identique au gel (H-F1-2).
- **Forme (D-F1-1) : contrat CLI seul, patron herdr-app.** herdr est un
  binaire seul — pas de `lib.rs` (E-F1-9) — l'adapter ne peut pas être une
  bibliothèque.
- **Surface :** `herdr --help` / `--version`, `herdr server
  stop|reload-config|reload-agent-manifests` (pas de lancement d'un serveur
  V5), commandes panes/workspaces/tabs/session/terminal/agent/machine,
  `herdr config check`, API machine via `herdr.sock` NDJSON (méthodes du
  schéma `docs/next/api/herdr-api.schema.json`, 10 759 lignes ; enveloppe
  `{id, method, params}` → `{id, result}` — explicitement PAS JSON-RPC 2.0,
  pas de champ `jsonrpc`).
- **Le serveur herdr n'est pas le daemon retiré (D-F1-2) :** c'est le serveur
  du TUI, distinct de `hc` — il reste un **serveur de l'opérateur, externe à
  V5**, comme le suppose `openrig_terminal.rs`. V5 ne le lance pas, ne le
  supervise pas, ne le réintroduit pas comme daemon.
- **Interrupteurs forcés (D-F1-5, H-F1-4) :** `[update] version_check = false`
  + `[update] manifest_check = false` — config embarquée
  `aspace-herdr-adapter/config.toml`, vérifiée au fichier ET par
  `herdr config check` (binaire adapté, chemin de config pointé par
  `HERDR_CONFIG_PATH`). Défaut amont : ON en production, vérifications
  d'arrière-plan toutes les 30 min (`AUTO_UPDATE_CHECK_INTERVAL`, T1/T2).
  `herdr update` et `herdr plugin update` restent hors contrat adapter
  (commandes non exposées, manuelles explicites).
- **Couture herdr ↔ herdr-core (E-F1-3) :** 0 lien de code inventé — les deux
  repos sont deux produits séparés à ces pins (0 occurrence de herdr-core
  dans herdr au gel). La couture nommée est (a) la bibliothèque adapter
  herdr-core comme client du protocole encadré `hc`, (b) l'adapter
  CLI-contrat herdr comme client du socket herdr NDJSON. Le natif consomme
  les deux voies séparément (D-F1-2).
- **Revendication 31415 (D-F1-6) :** le bind revendique
  `universal_harness_gateway_31415` +
  `http://127.0.0.1:31415/v1/chat/completions` — qualifiée côté A'Space
  (FreeCloud, `aspace_freecloud_gateway.py`), pas une capacité du gel
  (herdr ne sert rien sur 31415 au gel — 0 occurrence dans `src/`). Bind
  re-appliqué verbatim, non modifié au pas F1.
- **Smoke test :** `bash aspace-herdr-adapter/smoke_test.sh` (binaire debug,
  config scratch pointée par `HERDR_CONFIG_PATH` ; vérifie `--version`
  0.9.5, `--help`, `herdr server --help`, `herdr config check` → `config:
  ok` sur la config embarquée, et l'absence de `update`/`plugin update` de
  la surface du contrat). Aucun serveur herdr n'est lancé par le smoke.

## Tests au gel et sur le fork adapté

- **Au gel `ee5bfb5` :** voir
  `~/workspace/v4-factory/evidence/D-N053/f1/herdr/logs-suite-baseline-gel.log`
  (`cargo test --locked` — repli acté, `cargo-nextest` absent de la VM).
  Profils `render_scale_profile` (ignorés, perf) et tests Windows exclus.
  `ui-hot-path-architecture-test` et `integration-assets-test` exclus (hors
  périmètre sur cette VM, D-F1-7).
- **Sur l'adapté :** même suite + `maintenance-test` Python + `bun test
  scripts/release-workflows.test.ts` + `docs-contract-test` (`bun test
  ./scripts/docs`) + smoke adapter vert, sorties consignées sous
  `~/workspace/v4-factory/evidence/D-N053/f1/herdr/`.

## Télémétrie

**Zéro appel sortant par défaut.** Voir `herdr-TELEMETRY-AUDIT.md` : aucun
SDK de télémétrie, aucune crate HTTP (`reqwest`/`ureq`/`hyper`/`curl`
absents du `Cargo.lock`) ; tout le réseau passe par `curl` en
sous-processus ou par SSH, rien n'émet sans commande explicite, sauf T1/T2
(vérifications d'arrière-plan ON par défaut, coupées par l'adapter).
`herdr update` (T3), `herdr plugin update` (T4), remote SSH (T5) : manuels,
hors contrat. `docs/next/product-announcement.json` = `null` au gel, aucun
fetch. `zbus`/logind (Linux) : D-Bus local, pas réseau.

## Divergence (dette portée par le cœur Buzz, lane Clara / 12e)

- **Règles maison amont respectées (AGENTS.md) :** la racine `AGENTS.md`
  amont n'a PAS été éditée (H-M2) ; l'adapter ne touche pas au cœur.
- **Ré-audit télémétrie :** à chaque changement de commit gelé ou d'adapter,
  et au minimum à chaque transition d'état (D3).
- **Dette de divergence :** 0 commit au gel (dérive 0) ; toute dérive future
  se traite par amendement, jamais par fast-forward silencieux.

## Références

- Design pas F1 signé Clara (2026-11-12) :
  `~/workspace/v4-factory/plans/DESIGN-D-N053-PAS-F1-PROJET.md`.
- Discover pas F1 de Bill :
  `~/workspace/v4-factory/evidence/D-N053/f1/DISCOVER-PAS-F1.md`.
- Évidences : `~/workspace/v4-factory/evidence/D-N053/f1/herdr/`.
- Fork : https://github.com/Amdkn/herdr (gel `ee5bfb5`, adapter — voir
  manifeste).

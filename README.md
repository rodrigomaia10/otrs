# otrs_core — OTRS/Znuny da Cootravale

Versao do que roda em **producao**: Znuny **7.0.19** em `/opt/znuny` (servidor `172.31.3.170`, portal `chamados.cootravale.com.br/znuny`).
Homologacao: `192.168.1.221` (Znuny 7.0.19).

## Layout
Cada raiz **espelha os caminhos do servidor**: copiar `backend/` e `frontend/` por cima de `/opt/znuny` reconstroi a aplicacao.

| Pasta | Conteudo | Destino no servidor |
|---|---|---|
| `backend/` | `Kernel/`, `Custom/` (modulos Perl), `bin/`, `scripts/`, `Packages/` (.opm InBox/Znuny), `var/webservices`, `var/processes`, `var/cron` etc. | `/opt/znuny/` |
| `frontend/` | `var/httpd/htdocs` (CSS/JS/skins), templates `.tt` (`Kernel/Output/HTML/Templates` e `Custom/...`) | `/opt/znuny/` |
| `frontend/portal-css/` | CSS do portal do cliente colado em Admin → Custom Customer CSS (nao e arquivo do servidor) | via interface |
| `backups/` | Estado original antes de mudancas (CSS do portal, formulario 56) | — |
| `docs/` | Notas do projeto | — |
| `.claude/` | Skill `otrs-formulario-servico` | — |

## O que NAO esta no git (de proposito)
- `Kernel/Config.pm` (senha do banco) e `var/copilot-ws.secret` — ver `Kernel/Config.pm.dist` como modelo.
- `var/dynamicfield/` (~13 GB de anexos de chamados), `var/article`, logs, sessoes — dados de clientes (LGPD).
- `Kernel/Config/Files/ZZZAAuto.pm` (gerado), `scripts/test/` (fixtures com chaves de exemplo), `*.custom_backup`, `*.save`.
- Dados que vivem no **banco** (formularios de servico, campos dinamicos, filas, SysConfig) — exportar para `db/` quando formos versionar.

## Regras
- Producao so e alterada com autorizacao explicita; leitura via `plink -load OTRS` com `sudo`.
- Mudancas vao por branch + Pull Request; testar no HML antes da producao.
- Snapshot inicial tirado em 2026-10-16 do servidor de producao (somente leitura).

## Pacotes (.opm) de terceiros
`backend/Packages/` contem pacotes comerciais InBox; manter este repositorio **privado**.

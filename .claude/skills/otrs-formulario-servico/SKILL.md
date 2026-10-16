---
name: otrs-formulario-servico
description: Criar ou ajustar Formulários de Serviço no OTRS/Znuny da Cootravale (otrs.cootravale.com.br/znuny) pelo Chrome — campos dinâmicos, atribuição ao formulário, ordem e descrições. Use quando pedirem para "criar/montar/ajustar formulário de serviço", "campos dinâmicos" ou "formulário do chamado" no OTRS.
---

# Formulário de Serviço no OTRS Cootravale (Znuny)

Módulo customizado: **Admin → Formulário Customizado ↔ Serviço** (`Action=AdminCustomServiceForm`).
Cada formulário é ligado a um **Serviço**; os campos dinâmicos são atribuídos a ele com ordem, descrição curta, máscara, valor padrão e exibição (não exibir / exibir / mandatório).

## Fluxo (siga nesta ordem)
1. **Entender o pedido**: ler o chamado (`AgentTicketZoom;TicketID=N`) e extrair a lista de campos do questionário.
2. **Inventário (só leitura)**: abrir o formulário existente (`AdminCustomServiceForm;Subaction=ServiceFormEdit;ID=N`) e listar os campos atribuídos. Antes de criar campo novo, procure um existente com o mesmo rótulo/descrição (a lista tem ~500 campos).
3. **Backup**: gravar a lista de campos atribuídos e a ordem em arquivo local antes de mexer.
4. **Plano para o usuário**: dizer o que reaproveita, o que cria e o que remove. Esperar o "ok" antes de alterar o sistema.
5. **Criar campos novos** (se preciso), pela interface.
6. **Atribuir, remover e ordenar** no formulário. Salvar e **recarregar para conferir** o que foi gravado.
7. **Teste**: abrir o formulário em um chamado novo, **sem enviar**. Só criar chamado de teste se o usuário mandar; se ele pedir para validar, deixe com ele.

## Criar campo dinâmico de Texto (Chrome)
URL direta (precisa de `FieldOrder`, senão dá "Necessário FieldOrder"):
`/znuny/index.pl?Action=AdminDynamicFieldText;Subaction=Add;ObjectType=Ticket;FieldType=Text;FieldOrder=<n>`
- Clique em Nome (~555,230) e digite (só letras e números, único); clique em Rótulo (~555,326) e digite; **Enter** salva e volta à listagem.
- Use `FieldOrder` crescente (maior que o total de campos). Vários campos podem ir num `browser_batch`.
- Confirme depois que os campos existem e estão válidos.

## Editar o formulário (lista de campos) — pontos críticos
- A tela tem duas listas (`#AvailableFields` e `#AssignedFields`), com altura limitada. Via `javascript_tool` dá para esticar só visualmente: `AssignedFields.style.maxHeight='none'` e esconder (`display:none`) os disponíveis que não interessam; deixar `AvailableFields.style.minHeight` grande para ter onde soltar.
- **Atribuir**: arrastar com `left_click_drag` do disponível para o atribuído. Abre um modal de detalhes: **Salvar** com Exibir Campo (campo de texto tem Máscara, então o botão fica mais abaixo que no TextArea — olhe o screenshot).
- **Remover**: arrastar de volta para a lista de disponíveis.
- **Ordem**: reordenar o DOM de `#AssignedFields` com `appendChild` na ordem desejada e clicar em **Salvar** (não "Salvar e Finalizar") — a ordem persiste (confirmado ao recarregar).
- **Cuidado com o alvo do arrasto**: depois de `scrollIntoView`/modais a lista desloca. Sempre confira por screenshot (coordenadas do screenshot ≠ coordenadas CSS do JS; o frame do screenshot pode ser menor que o viewport) e verifique pelo DOM (`#AssignedFields` children) se o item certo moveu. Já houve arrasto do item errado (Cliente, MotoristaNome); mover de volta recria o item com **detalhes em branco**.
- Campos antigos podem ter **descrição curta** (aparece abaixo do rótulo). Leia antes de reaproveitar: `Antt` = "NOME PROP ANTT", `Telefone` = "TELEFONE PROPRIETARIO", `DataEmissao` = "DATA ANTT". Ajuste a descrição pelo ícone de edição do item se estiver errada.

## Teste de abertura
- `AgentTicketPhone`: escolher **Usuário cliente primeiro** (clicar na sugestão do autocomplete), depois a **fila** e depois o **serviço** (o serviço só habilita com cliente e fila). Para a matriz de risco: fila **GR** → serviço "Analise - Matriz de Risco - Analise Perfil".
- Ao clicar em campos depois de a página rolar, tire screenshot antes — um clique errado digita no corpo do chamado.
- **Não clique em Criar** sem o usuário pedir (gera chamado real, SLA e notificações).

## Limites e permissões
- O **Comandos SQL** (`AdminSelectBox`) só aceita SELECT e, em algumas sessões, é negado como "leitura em produção"; se negar, não contorne — use a interface.
- Não grave direto na base: a interface do Znuny cuida de cache e validação.
- Alterações no sistema (criar campos, mexer no formulário) só depois do "ok" do usuário; apagar campo do sistema, não — remover só a atribuição ao formulário.

## Referência: formulário "Analise - Matriz de Risco" (ID 56)
Serviço: Analise - Matriz de Risco - Analise Perfil · Disponível: Agente/Cliente.
Campos novos criados: `RefProf{1,2,3}{Nome,Empresa,Telefone}` (referências profissionais). Existentes reaproveitados: CAF motorista/proprietário, Cliente, Data, dados do motorista, `Antt`/`Telefone`/`DataEmissao`/`NewKMMCnpjCpf` (proprietário), rastreador (`RASTREADORTECNOLOGIA`, `Login`, `Senha`), `MotoristaRef1/2*` (referências pessoais), `OBS` e os anexos.

## Layout do formulario no portal do cliente (CSS)
- Portal: `https://chamados.cootravale.com.br/znuny/customer.pl?Action=NewTicketService;ServiceID=<id>` (Matriz de Risco = 214). O agente ja esta logado no mesmo Chrome do usuario; se cair no login, **o usuario faz o login** (nunca digite senha).
- Estrutura: `form#NewServiceTicket .row` > colunas `.col-md-4.Col_DynamicField_<Campo>` > `.card`. Escopo por formulario: `.row:has(> .Col_DynamicField_<CampoUnico>)` (Matriz de Risco usa `RefProf1Nome`). Assim o CSS nao afeta os outros formularios.
- Onde salvar: **Admin → Custom Customer CSS** (`AdminCustomerPortalCustomCSS`, editor CodeMirror, botao Salvar). Acrescentar **no final**, sem apagar o que ja existe; backup do original antes (`backups/`).
- Testar antes de salvar: injetar `<style id="testeMatrizCSS">` pela `javascript_tool` na pagina do portal (so na aba; recarregar desfaz).
- Titulos de secao: `::before` com `position:absolute; top:-40px` na primeira coluna da secao + `margin-top:46px` nas colunas da primeira linha. Colunas verticais: `display:grid` na `.row` com `grid-column`/`grid-row` explicitos por campo.
- O clique em **Salvar** do Manage CSS foi negado uma vez pelo classificador de permissoes; nao contornar — deixar o usuario clicar, ou pedir liberacao.
- **Causa do CSS nao aparecer (descoberta 16/10/2026):** o CSS fica no banco (`CustomPortalCSS`) e e injetado pelo filtro `CustomerPortalCustomCSS`, que so atua nos templates da SysConfig `Frontend::Output::FilterElementPost###CustomerPortalCustomCSS` (ativo: CustomerKanban, CustomerPortalFAQZoom, CustomerPortalFAQs, CustomerPortalSurvey, MyTickets, NewTicketProcess, Services). A pagina do formulario usa o template `NewTicketService`, que **nao esta na lista**. Correcao: adicionar `NewTicketService` nessa SysConfig (altera prod: so com permissao; testar no HML 192.168.1.221 antes). O filtro injeta no primeiro `</style>` da pagina.
- Repo git: `C:\project\otrs` (branch feat/versionamento-inicial); CSS em `frontend/portal-css/`, backups em `backups/`.

## Exportar/importar formulário entre ambientes (Admin → Formulário Customizado ↔ Serviço)
- **Exportar** (botão por linha) gera um `.yml` com nome/serviço/campos (por `Name`, não só ID) — sem segredos, pode ir pro git (`db/`).
- **Importar** com "Sobrescrever formulários existentes?" marcado: casa por nome; se o formulário de destino ja existe mas **faltam campos dinâmicos** no ambiente de destino, a importação **ignora silenciosamente** os campos que não existem — e reimportar depois de criar os campos **não atualiza** o registro já existente (nem por nome nem por ID). O caminho que funciona é criar os campos faltantes (Admin → Campos Dinâmicos, mesmo nome/tipo/opções da origem) e então **atribuir manualmente por drag-and-drop** na tela do formulário (`ServiceFormEdit;ID=<n>`).
- A importação pode criar o formulário com **um ID diferente** do original (não necessariamente reaproveita um ID vazio existente) — buscar pelo nome na listagem para achar o ID real.

## Atribuir campo por script (drag-and-drop automatizado)
- Esconder no `#AvailableFields` todos os `<li>` exceto o campo alvo (`display:none`), then `left_click_drag` do item visível pro `#AssignedFields`.
- **Escalar coordenadas**: o frame de coordenadas do `computer`/screenshot pode ser menor que o "Viewport" do `read_page` (ex. 1491x812 vs 1852x1009, fator ~0.805) — sempre multiplicar `getBoundingClientRect()` pelo fator antes de usar em clique/drag.
- O drop abre um modal "Editar Detalhes do Campo" cujo botão Salvar muda de posição conforme o tipo do campo (Texto com Máscara é mais alto que Checkbox/Multiselect/FileSystem) — recalcular via DOM a cada campo, não fixar coordenada.
- **NUNCA reordenar `#AssignedFields` via `appendChild`/manipulação direta do DOM antes de salvar** — corrompe o save (só persiste um prefixo dos itens, perdendo o resto). A ordem de exibição não importa quando o CSS usa `grid-column`/`grid-row` explícitos — só arrastar e salvar, sem reordenar.
- Para disparar submit por JS: `elementoDoForm.closest('form').requestSubmit()`, nunca `document.querySelector('form')` solto (pode pegar o form de busca do topo da página).

## Arquivos do projeto (C:\projects\otrs)
- `css/matriz_risco_portal_vertical.css` — layout em colunas verticais (versao atual escolhida).
- `css/matriz_risco_portal.css` — layout em linha (alternativa). `css/matriz_risco_layout.css` — teste inicial na tela do agente (obsoleto).
- `backups/backup_customer_css_original.css` — CSS custom do portal antes das mudancas. `backups/backup_form56_ordem_original.txt` — campos do formulario 56 antes das mudancas.

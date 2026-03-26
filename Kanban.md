📋 PRD & Technical Spec: Módulo Kanban para Chatwoot (SuperWoot)
1. Objetivo
Implementar uma visualização de Quadro Kanban nativa no Chatwoot para permitir o gerenciamento de conversas como cartões em um funil de vendas ou suporte.

2. Requisitos Funcionais
Colunas Dinâmicas: As colunas devem ser baseadas em Labels (Etiquetas) pré-existentes ou uma nova tabela de Stages.

Drag & Drop: Mover conversas entre colunas deve atualizar automaticamente a etiqueta/status da conversa no backend.

Filtros: Capacidade de filtrar o Kanban por Inbox, Equipe (Team) ou Agente.

Cards Detalhados: Exibir Nome do Contato, Avatar, Última Mensagem, Tempo desde a última resposta e Atribuído a.

3. Arquitetura Técnica
A. Backend (Ruby on Rails)
Model Migration:

Criar uma tabela kanban_settings para salvar a ordem das colunas por conta (account_id).

Adicionar um campo position na tabela labels (opcional, para ordenar colunas).

Controller:

Criar api/v1/accounts/{account_id}/kanban para retornar conversas agrupadas por etiquetas.

Endpoint PATCH para atualizar a etiqueta de uma conversa ao mover o card.

B. Frontend (Vue.js)
Dependência: Utilizar vuedraggable (já presente em algumas versões do Chatwoot ou fácil de adicionar via yarn).

Componentes:

KanbanBoard.vue: Container principal.

KanbanColumn.vue: Renderiza a lista de conversas de uma etiqueta específica.

KanbanCard.vue: Componente visual do card da conversa.

Estado (Vuex):

Criar um módulo kanban no diretório app/javascript/dashboard/store/modules/.

4. Guia de Implementação (Passo a Passo para a IA)
Passo 1: Definição das Rotas
Adicionar a rota do Kanban no arquivo:
app/javascript/dashboard/routes/dashboard/dashboard.routes.js

JavaScript
{
  path: 'kanban',
  name: 'kanban_dashboard',
  component: () => import('./views/KanbanView.vue'),
}
Passo 2: Estrutura da View
A KanbanView.vue deve realizar o dispatch para o Vuex buscando as conversas ativas e organizando-as em um objeto:

JSON
{
  "Novo Lead": [ { "id": 1, "contact": "Amílcar" } ],
  "Em Negociação": [ { "id": 2, "contact": "Daniel" } ]
}
Passo 3: Lógica de Atualização
Ao finalizar o drag-and-drop, disparar a action:
this.$store.dispatch('updateConversationLabel', { conversationId, newLabel });

5. Instruções para Deploy no Coolify (Docker Context)
Para garantir que as alterações reflitam no seu deploy:

Build Assets: O Coolify deve executar bundle exec rake assets:precompile durante o build.

Migrations: Garantir que bundle exec rake db:migrate rode no container de web.

Variavéis: Adicionar ENABLE_KANBAN=true no arquivo .env para controle de feature flag (opcional).

6. Definição de Pronto (DoD)
[ ] O usuário consegue visualizar colunas baseadas em etiquetas.

[ ] Ao arrastar um card, a etiqueta da conversa muda em tempo real.

[ ] A visualização funciona corretamente em telas de desktop.
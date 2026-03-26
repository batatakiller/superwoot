<script setup>
import { computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import draggable from 'vuedraggable';

const store = useStore();

// Obtém as conversas do store global
const conversations = computed(() => store.getters['conversations/getAll']);
// Obtém as etiquetas configuradas na conta
const labels = computed(() => store.getters['labels/getLabels']);

// Agrupa as conversas por etiqueta para exibição nas colunas
const kanbanData = computed({
  get: () => {
    const groups = {};
    // Criamos colunas para todas as etiquetas
    labels.value.forEach(label => {
      groups[label.title] = conversations.value.filter(conversation => 
        conversation.labels && conversation.labels.includes(label.title)
      );
    });
    return groups;
  },
  set: (newValue) => {
    // Opcional: Implementar reordenação de colunas salvando no backend
    console.log('Columns reordered:', newValue);
  }
});

/**
 * Lógica disparada ao soltar um card em uma nova coluna
 * @param {Object} event - Evento do vuedraggable
 * @param {String} newLabel - Nome da etiqueta da nova coluna
 */
const onCardDrop = (event, newLabel) => {
  if (event.added) {
    const conversationId = event.added.element.id;
    // Dispara a action para atualizar a etiqueta da conversa
    // Nota: 'updateConversationLabel' deve ser implementada no store se não existir
    store.dispatch('updateConversationLabel', { 
      conversationId, 
      newLabel 
    });
  }
};

onMounted(() => {
  // Inicialização básica de dados
  store.dispatch('labels/get');
  store.dispatch('conversations/get');
});
</script>

<template>
  <div class="flex h-full w-full overflow-x-auto bg-slate-50 dark:bg-slate-900 p-4 gap-4 items-start">
    <div 
      v-for="(cards, labelName) in kanbanData" 
      :key="labelName"
      class="flex-shrink-0 w-80 bg-slate-200 dark:bg-slate-800 rounded-lg flex flex-col max-h-full border border-slate-300 dark:border-slate-700"
    >
      <!-- Header da Coluna -->
      <div class="p-3 flex justify-between items-center bg-slate-100 dark:bg-slate-850 rounded-t-lg border-b border-slate-300 dark:border-slate-700">
        <h3 class="font-bold text-slate-700 dark:text-slate-200 uppercase text-xs tracking-wider truncate">
          {{ labelName }}
        </h3>
        <span class="px-2 py-0.5 bg-slate-300 dark:bg-slate-700 rounded-full text-[10px] font-bold">
          {{ cards.length }}
        </span>
      </div>

      <!-- Lista de Conversas Arrastáveis -->
      <draggable
        :list="cards"
        item-key="id"
        group="conversations"
        class="flex-1 overflow-y-auto p-2 min-h-[100px]"
        ghost-class="bg-blue-100 dark:bg-blue-900 opacity-50"
        @change="(e) => onCardDrop(e, labelName)"
      >
        <template #item="{ element }">
          <div 
            class="bg-white dark:bg-slate-700 p-3 mb-2 rounded shadow-sm border border-slate-200 dark:border-slate-600 cursor-grab active:cursor-grabbing hover:border-blue-400 dark:hover:border-blue-500 transition-all group"
          >
            <!-- Remetente -->
            <div class="flex items-center gap-2 mb-2">
              <img 
                v-if="element.meta.sender.thumbnail" 
                :src="element.meta.sender.thumbnail" 
                class="w-6 h-6 rounded-full border border-slate-200 dark:border-slate-600" 
              />
              <div v-else class="w-6 h-6 rounded-full bg-blue-500 flex items-center justify-center text-[10px] text-white font-bold">
                {{ element.meta.sender.name.charAt(0) }}
              </div>
              <span class="text-sm font-semibold truncate text-slate-800 dark:text-slate-100 italic">
                {{ element.meta.sender.name }}
              </span>
            </div>

            <!-- Última Mensagem -->
            <p class="text-xs text-slate-600 dark:text-slate-400 line-clamp-2 leading-relaxed">
              {{ element.messages && element.messages[0] ? element.messages[0].content : 'Nenhuma mensagem' }}
            </p>

            <!-- Rodapé do Card -->
            <div class="mt-3 flex justify-between items-center text-[10px] text-slate-400">
              <span>#{{ element.display_id }}</span>
              <span class="bg-slate-100 dark:bg-slate-800 px-1.5 py-0.5 rounded border border-slate-200 dark:border-slate-700">
                {{ element.status }}
              </span>
            </div>
          </div>
        </template>
      </draggable>
    </div>
  </div>
</template>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 10px;
}

.dark ::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
}
</style>

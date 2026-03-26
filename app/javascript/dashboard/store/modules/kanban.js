const state = {
  columnOrder: [],
  settings: {},
};

const getters = {
  getColumnOrder: $state => $state.columnOrder,
  getSettings: $state => $state.settings,
};

const actions = {
  saveSettings: async ({ commit }, { accountId, settings }) => {
    try {
      // API call to kanban_settings endpoint
      console.log('Saving settings for account:', accountId, settings);
      commit('SET_KANBAN_SETTINGS', settings);
    } catch (error) {
      console.error('Error saving kanban settings', error);
    }
  },
};

const mutations = {
  SET_KANBAN_SETTINGS: ($state, settings) => {
    $state.settings = settings;
    $state.columnOrder = settings.column_order || [];
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};

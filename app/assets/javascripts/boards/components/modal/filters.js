import FilteredSearchBoards from '../../filtered_search_boards';
import FilteredSearchContainer from '../../../filtered_search/container';

export default {
  name: 'modal-filters',
  props: {
    store: {
      type: Object,
      required: true,
    },
  },
  mounted() {
    FilteredSearchContainer.container = this.$el;

    this.filteredSearch = new FilteredSearchBoards(this.store);
    this.filteredSearch.removeTokens();
  },
  beforeDestroy() {
    this.filteredSearch.cleanup();
    FilteredSearchContainer.container = document;
    this.store.path = '';
  },
  template: '#js-board-modal-filter',
};

use std::sync::Arc;

use collab_database::fields::Field;
use collab_database::rows::{RowDetail, RowId};

use lib_infra::future::{to_fut, Fut};

use crate::services::cell::CellCache;
use crate::services::database_view::{
  gen_handler_id, DatabaseViewChangedNotifier, DatabaseViewOperation,
};
use crate::services::filter::{Filter, FilterController, FilterDelegate, FilterTaskHandler};

pub async fn make_filter_controller(
  view_id: &str,
  delegate: Arc<dyn DatabaseViewOperation>,
  notifier: DatabaseViewChangedNotifier,
  cell_cache: CellCache,
) -> Arc<FilterController> {
  let filters = delegate.get_all_filters(view_id);
  let task_scheduler = delegate.get_task_scheduler();
  let filter_delegate = DatabaseViewFilterDelegateImpl(delegate.clone());

  let handler_id = gen_handler_id();
  let filter_controller = FilterController::new(
    view_id,
    &handler_id,
    filter_delegate,
    task_scheduler.clone(),
    filters,
    cell_cache,
    notifier,
  )
  .await;
  let filter_controller = Arc::new(filter_controller);
  task_scheduler
    .write()
    .await
    .register_handler(FilterTaskHandler::new(
      handler_id,
      filter_controller.clone(),
    ));
  filter_controller
}

struct DatabaseViewFilterDelegateImpl(Arc<dyn DatabaseViewOperation>);
#[cfg_attr(target_arch = "wasm32", async_trait::async_trait(?Send))]
#[cfg_attr(not(target_arch = "wasm32"), async_trait::async_trait)]
impl FilterDelegate for DatabaseViewFilterDelegateImpl {
  async fn get_filter(&self, view_id: &str, filter_id: &str) -> Option<Arc<Filter>> {
    self.0.get_filter(view_id, filter_id).map(Arc::new)
  }

  fn get_field(&self, field_id: &str) -> Option<Field> {
    self.0.get_field(field_id)
  }

  async fn get_fields(&self, view_id: &str, field_ids: Option<Vec<String>>) -> Vec<Arc<Field>> {
    self.0.get_fields(view_id, field_ids).await
  }

  async fn get_rows(&self, view_id: &str) -> Vec<Arc<RowDetail>> {
    self.0.get_rows(view_id).await
  }

  async fn get_row(&self, view_id: &str, rows_id: &RowId) -> Option<(usize, Arc<RowDetail>)> {
    self.0.get_row(view_id, rows_id).await
  }
}

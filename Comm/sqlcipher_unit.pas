unit SqlCipher_Unit;

{$mode delphi}

interface

uses
  Classes,SysUtils,Sqlite3DS,CustomSqliteDS,db,strutils,sqlite3dyn;

const
  dllname='libsqlcipher.so';
const
  DBPass:AnsiString='TPLINK-123456;';

type
  Tsqlite3_key=function(db:Pointer;key:Pointer;nKey:integer):integer;cdecl;

var
  sqlite3_key:Tsqlite3_key=nil;

function InitDLL():Boolean;

implementation

var
  dllHandle:TLibHandle=0;



  procedure LoadAddresses(LibHandle: TLibHandle);
  begin
    sqlite3_libversion := GetProcedureAddress(LibHandle,'sqlite3_libversion');
    sqlite3_libversion_number:= GetProcedureAddress(LibHandle,'sqlite3_libversion_number');
    sqlite3_threadsafe:= GetProcedureAddress(LibHandle,'sqlite3_threadsafe');
    sqlite3_close:= GetProcedureAddress(LibHandle,'sqlite3_close');
    sqlite3_exec:= GetProcedureAddress(LibHandle,'sqlite3_exec');
    sqlite3_extended_result_codes:= GetProcedureAddress(LibHandle,'sqlite3_extended_result_codes');
    sqlite3_last_insert_rowid:= GetProcedureAddress(LibHandle,'sqlite3_last_insert_rowid');
    sqlite3_changes:= GetProcedureAddress(LibHandle,'sqlite3_changes');
    sqlite3_total_changes:= GetProcedureAddress(LibHandle,'sqlite3_total_changes');
    sqlite3_complete:= GetProcedureAddress(LibHandle,'sqlite3_complete');
    sqlite3_complete16:= GetProcedureAddress(LibHandle,'sqlite3_complete16');
    sqlite3_busy_handler:= GetProcedureAddress(LibHandle,'sqlite3_busy_handler');
    sqlite3_busy_timeout:= GetProcedureAddress(LibHandle,'sqlite3_busy_timeout');
    sqlite3_get_table:= GetProcedureAddress(LibHandle,'sqlite3_get_table');
    sqlite3_malloc:= GetProcedureAddress(LibHandle,'sqlite3_malloc');
    sqlite3_realloc:= GetProcedureAddress(LibHandle,'sqlite3_realloc');
    sqlite3_memory_used:= GetProcedureAddress(LibHandle,'sqlite3_memory_used');
    sqlite3_memory_highwater:= GetProcedureAddress(LibHandle,'sqlite3_memory_highwater');
    sqlite3_set_authorizer:= GetProcedureAddress(LibHandle,'sqlite3_set_authorizer');
    sqlite3_trace:= GetProcedureAddress(LibHandle,'sqlite3_trace');
    sqlite3_profile:= GetProcedureAddress(LibHandle,'sqlite3_profile');
    sqlite3_open:= GetProcedureAddress(LibHandle,'sqlite3_open');
    sqlite3_open16:= GetProcedureAddress(LibHandle,'sqlite3_open16');
    sqlite3_open_v2:= GetProcedureAddress(LibHandle,'sqlite3_open_v2');
    sqlite3_errcode:= GetProcedureAddress(LibHandle,'sqlite3_errcode');
    sqlite3_extended_errcode:= GetProcedureAddress(LibHandle,'sqlite3_extended_errcode');
    sqlite3_errmsg:= GetProcedureAddress(LibHandle,'sqlite3_errmsg');
    sqlite3_errmsg16:= GetProcedureAddress(LibHandle,'sqlite3_errmsg16');
    sqlite3_limit:= GetProcedureAddress(LibHandle,'sqlite3_limit');
    sqlite3_prepare:= GetProcedureAddress(LibHandle,'sqlite3_prepare');
    sqlite3_prepare_v2:= GetProcedureAddress(LibHandle,'sqlite3_prepare_v2');
    sqlite3_prepare16:= GetProcedureAddress(LibHandle,'sqlite3_prepare16');
    sqlite3_prepare16_v2:= GetProcedureAddress(LibHandle,'sqlite3_prepare16_v2');
    sqlite3_sql:= GetProcedureAddress(LibHandle,'sqlite3_sql');
    sqlite3_bind_blob:= GetProcedureAddress(LibHandle,'sqlite3_bind_blob');
    sqlite3_bind_double:= GetProcedureAddress(LibHandle,'sqlite3_bind_double');
    sqlite3_bind_int:= GetProcedureAddress(LibHandle,'sqlite3_bind_int');
    sqlite3_bind_int64:= GetProcedureAddress(LibHandle,'sqlite3_bind_int64');
    sqlite3_bind_null:= GetProcedureAddress(LibHandle,'sqlite3_bind_null');
    sqlite3_bind_text:= GetProcedureAddress(LibHandle,'sqlite3_bind_text');
    sqlite3_bind_text16:= GetProcedureAddress(LibHandle,'sqlite3_bind_text16');
    sqlite3_bind_value:= GetProcedureAddress(LibHandle,'sqlite3_bind_value');
    sqlite3_bind_zeroblob:= GetProcedureAddress(LibHandle,'sqlite3_bind_zeroblob');
    sqlite3_bind_parameter_count:= GetProcedureAddress(LibHandle,'sqlite3_bind_parameter_count');
    sqlite3_bind_parameter_name:= GetProcedureAddress(LibHandle,'sqlite3_bind_parameter_name');
    sqlite3_bind_parameter_index:= GetProcedureAddress(LibHandle,'sqlite3_bind_parameter_index');
    sqlite3_clear_bindings:= GetProcedureAddress(LibHandle,'sqlite3_clear_bindings');
    sqlite3_column_count:= GetProcedureAddress(LibHandle,'sqlite3_column_count');
    sqlite3_column_name:= GetProcedureAddress(LibHandle,'sqlite3_column_name');
    sqlite3_column_name16:= GetProcedureAddress(LibHandle,'sqlite3_column_name16');
    sqlite3_column_database_name:= GetProcedureAddress(LibHandle,'sqlite3_column_database_name');
    sqlite3_column_database_name16:= GetProcedureAddress(LibHandle,'sqlite3_column_database_name16');
    sqlite3_column_table_name:= GetProcedureAddress(LibHandle,'sqlite3_column_table_name');
    sqlite3_column_table_name16:= GetProcedureAddress(LibHandle,'sqlite3_column_table_name16');
    sqlite3_column_origin_name:= GetProcedureAddress(LibHandle,'sqlite3_column_origin_name');
    sqlite3_column_origin_name16:= GetProcedureAddress(LibHandle,'sqlite3_column_origin_name16');
    sqlite3_column_decltype:= GetProcedureAddress(LibHandle,'sqlite3_column_decltype');
    sqlite3_column_decltype16:= GetProcedureAddress(LibHandle,'sqlite3_column_decltype16');
    sqlite3_step:= GetProcedureAddress(LibHandle,'sqlite3_step');
    sqlite3_data_count:= GetProcedureAddress(LibHandle,'sqlite3_data_count');
    sqlite3_column_blob:= GetProcedureAddress(LibHandle,'sqlite3_column_blob');
    sqlite3_column_bytes:= GetProcedureAddress(LibHandle,'sqlite3_column_bytes');
    sqlite3_column_bytes16:= GetProcedureAddress(LibHandle,'sqlite3_column_bytes16');
    sqlite3_column_double:= GetProcedureAddress(LibHandle,'sqlite3_column_double');
    sqlite3_column_int:= GetProcedureAddress(LibHandle,'sqlite3_column_int');
    sqlite3_column_int64:= GetProcedureAddress(LibHandle,'sqlite3_column_int64');
    sqlite3_column_text:= GetProcedureAddress(LibHandle,'sqlite3_column_text');
    sqlite3_column_text16:= GetProcedureAddress(LibHandle,'sqlite3_column_text16');
    sqlite3_column_type:= GetProcedureAddress(LibHandle,'sqlite3_column_type');
    sqlite3_column_value:= GetProcedureAddress(LibHandle,'sqlite3_column_value');
    sqlite3_finalize:= GetProcedureAddress(LibHandle,'sqlite3_finalize');
    sqlite3_reset:= GetProcedureAddress(LibHandle,'sqlite3_reset');
    sqlite3_create_function:= GetProcedureAddress(LibHandle,'sqlite3_create_function');
    sqlite3_create_function16:= GetProcedureAddress(LibHandle,'sqlite3_create_function16');
    sqlite3_create_function_v2:= GetProcedureAddress(LibHandle,'sqlite3_create_function_v2');
    sqlite3_value_blob:= GetProcedureAddress(LibHandle,'sqlite3_value_blob');
    sqlite3_value_bytes:= GetProcedureAddress(LibHandle,'sqlite3_value_bytes');
    sqlite3_value_bytes16:= GetProcedureAddress(LibHandle,'sqlite3_value_bytes16');
    sqlite3_value_double:= GetProcedureAddress(LibHandle,'sqlite3_value_double');
    sqlite3_value_int:= GetProcedureAddress(LibHandle,'sqlite3_value_int');
    sqlite3_value_int64:= GetProcedureAddress(LibHandle,'sqlite3_value_int64');
    sqlite3_value_text:= GetProcedureAddress(LibHandle,'sqlite3_value_text');
    sqlite3_value_text16:= GetProcedureAddress(LibHandle,'sqlite3_value_text16');
    sqlite3_value_text16le:= GetProcedureAddress(LibHandle,'sqlite3_value_text16le');
    sqlite3_value_text16be:= GetProcedureAddress(LibHandle,'sqlite3_value_text16be');
    sqlite3_value_type:= GetProcedureAddress(LibHandle,'sqlite3_value_type');
    sqlite3_value_numeric_type:= GetProcedureAddress(LibHandle,'sqlite3_value_numeric_type');
    sqlite3_aggregate_context:= GetProcedureAddress(LibHandle,'sqlite3_aggregate_context');
    sqlite3_user_data:= GetProcedureAddress(LibHandle,'sqlite3_user_data');
    sqlite3_context_db_handle:= GetProcedureAddress(LibHandle,'sqlite3_context_db_handle');
    sqlite3_get_auxdata:= GetProcedureAddress(LibHandle,'sqlite3_get_auxdata');
    sqlite3_create_collation:= GetProcedureAddress(LibHandle,'sqlite3_create_collation');
    sqlite3_create_collation_v2:= GetProcedureAddress(LibHandle,'sqlite3_create_collation_v2');
    sqlite3_create_collation16:= GetProcedureAddress(LibHandle,'sqlite3_create_collation16');
    sqlite3_collation_needed:= GetProcedureAddress(LibHandle,'sqlite3_collation_needed');
    sqlite3_collation_needed16:= GetProcedureAddress(LibHandle,'sqlite3_collation_needed16');
    sqlite3_key:= GetProcedureAddress(LibHandle,'sqlite3_key');
    sqlite3_rekey:= GetProcedureAddress(LibHandle,'sqlite3_rekey');
    sqlite3_sleep:= GetProcedureAddress(LibHandle,'sqlite3_sleep');
    sqlite3_get_autocommit:= GetProcedureAddress(LibHandle,'sqlite3_get_autocommit');
    sqlite3_db_handle:= GetProcedureAddress(LibHandle,'sqlite3_db_handle');
    sqlite3_commit_hook:= GetProcedureAddress(LibHandle,'sqlite3_commit_hook');
    sqlite3_rollback_hook:= GetProcedureAddress(LibHandle,'sqlite3_rollback_hook');
    sqlite3_update_hook:= GetProcedureAddress(LibHandle,'sqlite3_update_hook');
    sqlite3_enable_shared_cache:= GetProcedureAddress(LibHandle,'sqlite3_enable_shared_cache');
    sqlite3_release_memory:= GetProcedureAddress(LibHandle,'sqlite3_release_memory');
    sqlite3_table_column_metadata:= GetProcedureAddress(LibHandle,'sqlite3_table_column_metadata');
    sqlite3_load_extension:= GetProcedureAddress(LibHandle,'sqlite3_load_extension');
    sqlite3_enable_load_extension:= GetProcedureAddress(LibHandle,'sqlite3_enable_load_extension');
    sqlite3_auto_extension:= GetProcedureAddress(LibHandle,'sqlite3_auto_extension');
    sqlite3_create_module:= GetProcedureAddress(LibHandle,'sqlite3_create_module');
    sqlite3_create_module_v2:= GetProcedureAddress(LibHandle,'sqlite3_create_module_v2');
    sqlite3_declare_vtab:= GetProcedureAddress(LibHandle,'sqlite3_declare_vtab');
    sqlite3_overload_function:= GetProcedureAddress(LibHandle,'sqlite3_overload_function');
    sqlite3_blob_open:= GetProcedureAddress(LibHandle,'sqlite3_blob_open');
    sqlite3_blob_reopen:= GetProcedureAddress(LibHandle,'sqlite3_blob_reopen');
    sqlite3_blob_close:= GetProcedureAddress(LibHandle,'sqlite3_blob_close');
    sqlite3_blob_bytes:= GetProcedureAddress(LibHandle,'sqlite3_blob_bytes');
    sqlite3_blob_read:= GetProcedureAddress(LibHandle,'sqlite3_blob_read');
    sqlite3_blob_write:= GetProcedureAddress(LibHandle,'sqlite3_blob_write');
    sqlite3_vfs_find:= GetProcedureAddress(LibHandle,'sqlite3_vfs_find');
    sqlite3_vfs_register:= GetProcedureAddress(LibHandle,'sqlite3_vfs_register');
    sqlite3_vfs_unregister:= GetProcedureAddress(LibHandle,'sqlite3_vfs_unregister');
    sqlite3_mutex_alloc:= GetProcedureAddress(LibHandle,'sqlite3_mutex_alloc');
    sqlite3_mutex_try:= GetProcedureAddress(LibHandle,'sqlite3_mutex_try');
    sqlite3_mutex_held:= GetProcedureAddress(LibHandle,'sqlite3_mutex_held');
    sqlite3_mutex_notheld:= GetProcedureAddress(LibHandle,'sqlite3_mutex_notheld');
    sqlite3_db_mutex:= GetProcedureAddress(LibHandle,'sqlite3_db_mutex');
    sqlite3_file_control:= GetProcedureAddress(LibHandle,'sqlite3_file_control');
    sqlite3_test_control:= GetProcedureAddress(LibHandle,'sqlite3_test_control');
    sqlite3_status:= GetProcedureAddress(LibHandle,'sqlite3_status');
    sqlite3_db_status:= GetProcedureAddress(LibHandle,'sqlite3_db_status');
    sqlite3_stmt_status:= GetProcedureAddress(LibHandle,'sqlite3_stmt_status');
    sqlite3_interrupt:= GetProcedureAddress(LibHandle,'sqlite3_interrupt');
    sqlite3_free_table:= GetProcedureAddress(LibHandle,'sqlite3_free_table');
    sqlite3_free:= GetProcedureAddress(LibHandle,'sqlite3_free');
    sqlite3_randomness:= GetProcedureAddress(LibHandle,'sqlite3_randomness');
    sqlite3_progress_handler:= GetProcedureAddress(LibHandle,'sqlite3_progress_handler');
    sqlite3_set_auxdata:= GetProcedureAddress(LibHandle,'sqlite3_set_auxdata');
    sqlite3_result_blob:= GetProcedureAddress(LibHandle,'sqlite3_result_blob');
    sqlite3_result_double:= GetProcedureAddress(LibHandle,'sqlite3_result_double');
    sqlite3_result_error:= GetProcedureAddress(LibHandle,'sqlite3_result_error');
    sqlite3_result_error16:= GetProcedureAddress(LibHandle,'sqlite3_result_error16');
    sqlite3_result_error_toobig:= GetProcedureAddress(LibHandle,'sqlite3_result_error_toobig');
    sqlite3_result_error_nomem:= GetProcedureAddress(LibHandle,'sqlite3_result_error_nomem');
    sqlite3_result_error_code:= GetProcedureAddress(LibHandle,'sqlite3_result_error_code');
    sqlite3_result_int:= GetProcedureAddress(LibHandle,'sqlite3_result_int');
    sqlite3_result_int64:= GetProcedureAddress(LibHandle,'sqlite3_result_int64');
    sqlite3_result_null:= GetProcedureAddress(LibHandle,'sqlite3_result_null');
    sqlite3_result_text:= GetProcedureAddress(LibHandle,'sqlite3_result_text');
    sqlite3_result_text16:= GetProcedureAddress(LibHandle,'sqlite3_result_text16');
    sqlite3_result_text16le:= GetProcedureAddress(LibHandle,'sqlite3_result_text16le');
    sqlite3_result_text16be:= GetProcedureAddress(LibHandle,'sqlite3_result_text16be');
    sqlite3_result_value:= GetProcedureAddress(LibHandle,'sqlite3_result_value');
    sqlite3_result_zeroblob:= GetProcedureAddress(LibHandle,'sqlite3_result_zeroblob');
    sqlite3_soft_heap_limit:= GetProcedureAddress(LibHandle,'sqlite3_soft_heap_limit');
    sqlite3_soft_heap_limit64:= GetProcedureAddress(LibHandle,'sqlite3_soft_heap_limit64');
    sqlite3_reset_auto_extension:= GetProcedureAddress(LibHandle,'sqlite3_reset_auto_extension');
    sqlite3_mutex_free:= GetProcedureAddress(LibHandle,'sqlite3_mutex_free');
    sqlite3_mutex_ente:= GetProcedureAddress(LibHandle,'sqlite3_mutex_ente');
    sqlite3_mutex_leave:= GetProcedureAddress(LibHandle,'sqlite3_mutex_leave');
    sqlite3_backup_init:= GetProcedureAddress(LibHandle,'sqlite3_backup_init');
    sqlite3_backup_step:= GetProcedureAddress(LibHandle,'sqlite3_backup_step');
    sqlite3_backup_finish:= GetProcedureAddress(LibHandle,'sqlite3_backup_finish');
    sqlite3_backup_remaining:= GetProcedureAddress(LibHandle,'sqlite3_backup_remaining');
    sqlite3_backup_pagecount:= GetProcedureAddress(LibHandle,'sqlite3_backup_pagecount');
    sqlite3_unlock_notify:= GetProcedureAddress(LibHandle,'sqlite3_unlock_notify');
    sqlite3_log:= GetProcedureAddress(LibHandle,'sqlite3_log');
    sqlite3_wal_hook:= GetProcedureAddress(LibHandle,'sqlite3_wal_hook');
    sqlite3_wal_autocheckpoint:= GetProcedureAddress(LibHandle,'sqlite3_wal_autocheckpoint');
    sqlite3_wal_checkpoint:= GetProcedureAddress(LibHandle,'sqlite3_wal_checkpoint');
    sqlite3_wal_checkpoint_v2:= GetProcedureAddress(LibHandle,'sqlite3_wal_checkpoint_v2');


    sqlite3_initialize:= GetProcedureAddress(LibHandle,'sqlite3_initialize');
    sqlite3_shutdown:= GetProcedureAddress(LibHandle,'sqlite3_shutdown');
    sqlite3_os_init:= GetProcedureAddress(LibHandle,'sqlite3_os_init');
    sqlite3_os_end:= GetProcedureAddress(LibHandle,'sqlite3_os_end');
    sqlite3_config:= GetProcedureAddress(LibHandle,'sqlite3_config');
    sqlite3_db_config:= GetProcedureAddress(LibHandle,'sqlite3_db_config');
    sqlite3_uri_parameter:= GetProcedureAddress(LibHandle,'sqlite3_uri_parameter');

  {$IFDEF SQLITE_OBSOLETE}
    sqlite3_aggregate_count:= GetProcedureAddress(LibHandle,'sqlite3_aggregate_count');
    sqlite3_expired:= GetProcedureAddress(LibHandle,'sqlite3_expired');
    sqlite3_transfer_bindings:= GetProcedureAddress(LibHandle,'sqlite3_transfer_bindings');
    sqlite3_global_recover:= GetProcedureAddress(LibHandle,'sqlite3_global_recover');
    sqlite3_memory_alarm:= GetProcedureAddress(LibHandle,'sqlite3_memory_alarm');
    sqlite3_thread_cleanup:= GetProcedureAddress(LibHandle,'sqlite3_thread_cleanup');
  {$ENDIF}
  end;



function InitDLL():Boolean;
begin
  Result:=false;
  dllHandle:=system.SafeLoadLibrary(dllname);
  if dllHandle=0 then
  exit;
  sqlite3_key:=system.GetProcedureAddress(dllHandle,'sqlite3_key');
  if system.Assigned(sqlite3_key) then
  Result:=true;

  LoadAddresses(dllHandle);
end;




end.


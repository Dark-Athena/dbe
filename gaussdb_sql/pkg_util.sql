-- DROP SCHEMA pkg_util;

CREATE SCHEMA pkg_util AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION pkg_util.app_read_client_info(OUT buffer text)
 RETURNS text
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$read_client_info$function$;

CREATE OR REPLACE FUNCTION pkg_util.app_set_client_info(str text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_client_info$function$;

CREATE OR REPLACE FUNCTION pkg_util.exception_report_error(code integer, log text, flag boolean DEFAULT false)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pg_catalog.report_application_error(log, code);
END;
$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_block_size(file_name text)
 RETURNS bigint
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_block_size$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_close(file integer)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_close$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_close_all()
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_close_all$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_exists(file_name text)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_exists$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_flush(file integer)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_flush$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_getpos(file integer)
 RETURNS bigint
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_getpos$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_is_close(file integer)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_is_close$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_newline(file integer)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_writeline$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_open(file_name text, open_mode text, change_mode text, encoding name)
 RETURNS integer
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_open$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_open(file_name text, open_mode text, change_mode text)
 RETURNS integer
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_open$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_open(file_name text, open_mode text)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_open$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_read(file integer, OUT buffer text, len bigint DEFAULT 1024)
 RETURNS text
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_read$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_read_raw(file integer, length integer DEFAULT NULL::integer)
 RETURNS raw
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_read_raw$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_readline(file integer, OUT buffer text, len integer DEFAULT 1024)
 RETURNS text
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_readline$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_remove(file_name text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_remove$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_rename(src_dir text, src_file_name text, dest_dir text, dest_file_name text, overwrite boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_rename$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_seek(file integer, start_pos bigint)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_seek$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_set_dirname(dir text)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_set_dirname$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_set_max_line_size(max_line_size integer)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_set_maxline_size$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_size(file_name text)
 RETURNS bigint
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_size$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_write(file integer, buffer text)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_write$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_write_raw(file integer, r raw)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_write_raw$function$;

CREATE OR REPLACE FUNCTION pkg_util.file_writeline(file integer, buffer text)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_writeline$function$;

CREATE OR REPLACE FUNCTION pkg_util.format_write(file integer, format text, arg1 text DEFAULT NULL::text, arg2 text DEFAULT NULL::text, arg3 text DEFAULT NULL::text, arg4 text DEFAULT NULL::text, arg5 text DEFAULT NULL::text, arg6 text DEFAULT NULL::text)
 RETURNS boolean
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_format_write$function$;

CREATE OR REPLACE FUNCTION pkg_util.io_print(format text, is_one_line boolean)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$io_print$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_append(INOUT clob, clob, integer DEFAULT NULL::integer)
 RETURNS clob
 LANGUAGE c
 NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$clob_append$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_append(INOUT dest_lob blob, src_lob blob, len integer DEFAULT NULL::integer)
 RETURNS blob
 LANGUAGE c
 NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$blob_append$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_compare(lob1 anyelement, lob2 anyelement, len integer DEFAULT 1073741771, start_pos1 integer DEFAULT 1, start_pos2 integer DEFAULT 1)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$lob_compare$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_converttoblob(dest_lob blob, src_clob clob, amount integer, dest_offset integer, src_offset integer)
 RETURNS raw
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$converttoblob$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_converttoclob(dest_lob clob, src_blob blob, amount integer, dest_offset integer, src_offset integer)
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$converttoclob$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_get_length(lob anyelement)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$lob_get_length$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_match(lob anyelement, pattern anyelement, start_pos integer, match_nth integer DEFAULT 1)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$lob_match$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_rawtotext(src_lob blob)
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$cast_raw_to_text$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_read(lob anyelement, len integer, start_pos integer, mode integer)
 RETURNS anyelement
 LANGUAGE c
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$lob_read$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_reset(INOUT lob blob, INOUT len integer, start_pos integer DEFAULT 1, value integer DEFAULT 0)
 RETURNS record
 LANGUAGE c
 STRICT NOT FENCED SHIPPABLE
AS '$libdir/packages', $function$lob_reset$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_texttoraw(src_lob clob)
 RETURNS raw
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$cast_text_to_raw$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_write(INOUT dest_lob clob, src_lob character varying, len integer, start_pos integer)
 RETURNS clob
 LANGUAGE c
 NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$lob_write$function$;

CREATE OR REPLACE FUNCTION pkg_util.lob_write(INOUT dest_lob blob, src_lob raw, len integer, start_pos integer)
 RETURNS blob
 LANGUAGE c
 NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$lob_write$function$;

CREATE OR REPLACE FUNCTION pkg_util.match_edit_distance_similarity(str1 text, str2 text)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$edit_distance_similarity$function$;

CREATE OR REPLACE FUNCTION pkg_util.random_get_value()
 RETURNS numeric
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$random_get_value$function$;

CREATE OR REPLACE FUNCTION pkg_util.random_set_seed(seed integer)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$random_set_seed$function$;

CREATE OR REPLACE FUNCTION pkg_util.raw_cast_from_binary_integer(value integer, endianess integer)
 RETURNS raw
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$cast_from_binary_integer_to_raw$function$;

CREATE OR REPLACE FUNCTION pkg_util.raw_cast_from_varchar2(str character varying)
 RETURNS raw
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$cast_varchar_to_raw$function$;

CREATE OR REPLACE FUNCTION pkg_util.raw_cast_to_binary_integer(value raw, endianess integer)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$cast_raw_to_binary_integer$function$;

CREATE OR REPLACE FUNCTION pkg_util.raw_cast_to_varchar2(str raw)
 RETURNS character varying
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$cast_to_varchar2$function$;

CREATE OR REPLACE FUNCTION pkg_util.raw_get_length(value raw)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$raw_get_length$function$;

CREATE OR REPLACE FUNCTION pkg_util.session_clear_context(namespace text, client_identifier text, attribute text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$clear_context$function$;

CREATE OR REPLACE FUNCTION pkg_util.session_search_context(namespace text, attribute text)
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$search_context$function$;

CREATE OR REPLACE FUNCTION pkg_util.session_set_context(namespace text, attribute text, value text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_context$function$;

CREATE OR REPLACE FUNCTION pkg_util.utility_format_call_stack()
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$format_call_stack$function$;

CREATE OR REPLACE FUNCTION pkg_util.utility_format_error_backtrace()
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$format_error_backtrace$function$;

CREATE OR REPLACE FUNCTION pkg_util.utility_format_error_stack()
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$format_error_stack$function$;

CREATE OR REPLACE FUNCTION pkg_util.utility_get_time()
 RETURNS bigint
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$get_time$function$;

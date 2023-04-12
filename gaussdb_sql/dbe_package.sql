CREATE SCHEMA dbe_application_info AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_application_info.read_client_info(OUT client_info text)
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    client_info := pkg_util.app_read_client_info();
    return client_info;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_application_info.set_client_info(str text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pkg_util.app_set_client_info(str);
END;
$function$;

-- DROP SCHEMA dbe_file;

CREATE SCHEMA dbe_file AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_file.close_all()
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  pkg_util.file_close_all();
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.copy(src_dir text, src_file_name text, dest_dir text, dest_file_name text, start_line integer DEFAULT 1, end_line integer DEFAULT NULL::integer)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
  f integer;
  f1 integer;
  ret_val text;
  i integer;
  exists bool;
BEGIN
  if start_line < 1 then
	RAISE EXCEPTION 'The start_line should be more than 0.';
  end if;
  if end_line IS NOT NULL AND end_line < 1 then
    RAISE EXCEPTION 'The end_line should be more than 0.';
  end if;
  if end_line < start_line then
    RAISE EXCEPTION 'The end_line should be greater than or equal to start_line.';
  end if;
  PERFORM pkg_util.file_set_dirname(src_dir);
  exists := pkg_util.file_exists(src_file_name);
  if exists != true then
    RAISE EXCEPTION 'The source file does not exists.';
  end if;
  PERFORM pkg_util.file_set_dirname(dest_dir);
  exists := pkg_util.file_exists(dest_file_name);
  if exists = true then
    pkg_util.file_remove(dest_file_name);
  end if;
  PERFORM pkg_util.file_set_dirname(src_dir);
  f := pkg_util.file_open(src_file_name, 'r');
  PERFORM pkg_util.file_set_dirname(dest_dir);
  f1 := pkg_util.file_open(dest_file_name, 'w');
  pkg_util.file_readline(f, ret_val);
  i := 1;
  WHILE ret_val IS NOT NULL LOOP
    if i < start_line then
      i := i + 1;
      pkg_util.file_readline(f, ret_val);
      continue;
    end if;
    if end_line IS NOT NULL and i > end_line then
      exit;
    end if;
    if ret_val = '\n' then
      PERFORM pkg_util.file_newline(f1);
    else
      PERFORM pkg_util.file_writeline(f1, ret_val);
    end if;
    pkg_util.file_readline(f, ret_val);
    i := i + 1;
  END LOOP;
  PERFORM pkg_util.file_close(f);
  PERFORM pkg_util.file_close(f1);
  EXCEPTION
    WHEN others THEN
	  PERFORM pkg_util.file_close(f);
      PERFORM pkg_util.file_close(f1);
	  if sqlerrm != 'no data found' then
		RAISE EXCEPTION '% ', sqlerrm;
	  end if;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.flush(file integer)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  pkg_util.file_flush(file);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.format_write(file integer, format text, arg1 text DEFAULT NULL::text, arg2 text DEFAULT NULL::text, arg3 text DEFAULT NULL::text, arg4 text DEFAULT NULL::text, arg5 text DEFAULT NULL::text, arg6 text DEFAULT NULL::text)
 RETURNS boolean
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  RETURN pkg_util.format_write(file, format, arg1, arg2, arg3, arg4, arg5, arg6);
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_file.get_attr(location text,
											filename text,
											OUT fexists boolean,
											OUT file_length bigint,
											OUT block_size integer)
AS  DECLARE 
BEGIN
  PERFORM pkg_util.file_set_dirname(location);
  fexists := pkg_util.file_exists(filename);
  if fexists = true then
    file_length := pkg_util.file_size(filename);
    block_size := pkg_util.file_block_size(filename);
  else
    file_length = null;
	  block_size = null;
  end if;
END;
/;

CREATE OR REPLACE FUNCTION dbe_file.get_pos(file integer)
 RETURNS bigint
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  RETURN pkg_util.file_getpos(file);
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_file.get_raw(file in integer, r out raw, length in integer default NULL)
AS  DECLARE 
BEGIN
   r := pkg_util.file_read_raw(file, length);
END;
/;

CREATE OR REPLACE FUNCTION dbe_file.is_close(file integer)
 RETURNS boolean
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  RETURN pkg_util.file_is_close(file);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.is_open(file integer)
 RETURNS boolean
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
  is_close bool;
BEGIN
  is_close := false;
  is_close := DBE_FILE.is_close(file);
  if is_close = true then
      RETURN false;
  end if;
  RETURN true;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.new_line(file integer, line_nums integer DEFAULT 1)
 RETURNS boolean
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
  has_write bool;
BEGIN
  has_write := false;
  for loop_counter in 1..line_nums loop
    has_write := pkg_util.file_newline(file);
    if has_write = false then
      RETURN false;
    end if;
  end loop;
  RETURN true;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.open(dir text, file_name text, open_mode text, max_line_size integer, chmode text)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  PERFORM pkg_util.file_set_dirname(dir);
  PERFORM pkg_util.file_set_max_line_size(max_line_size);
  RETURN pkg_util.file_open(file_name, open_mode, chmode);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.open(dir text, file_name text, open_mode text, max_line_size integer DEFAULT 1024)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  PERFORM pkg_util.file_set_dirname(dir);
  PERFORM pkg_util.file_set_max_line_size(max_line_size);
  RETURN pkg_util.file_open(file_name, open_mode);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.open_en(dir text, file_name text, open_mode text, max_line_size integer, chmode text, encoding name)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  PERFORM pkg_util.file_set_dirname(dir);
  PERFORM pkg_util.file_set_max_line_size(max_line_size);
  RETURN pkg_util.file_open(file_name, open_mode, chmode, encoding);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.put_raw(file integer, r raw, flush boolean DEFAULT false)
 RETURNS boolean
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
   has_write bool;
BEGIN
    if flush = false then
     return pkg_util.file_write_raw(file, r);
    else
     has_write := pkg_util.file_write_raw(file, r);
     if has_write = true then
      PERFORM pkg_util.file_flush(file);
     end if;
    end if;
    RETURN has_write;
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_file.read_line(file integer, OUT buffer text, len integer DEFAULT NULL)
AS  DECLARE 
BEGIN
  buffer := pkg_util.file_readline(file, buffer, len);
END;
/;

CREATE OR REPLACE FUNCTION dbe_file.remove(dir text, file_name text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  pkg_util.file_set_dirname(dir);
  pkg_util.file_remove(file_name);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.rename(dir text, src_file_name text, dest_dir text, dest_file_name text, overwrite boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
	pkg_util.file_rename(dir, src_file_name, dest_dir, dest_file_name, overwrite);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.seek(file integer, absolute_start bigint DEFAULT NULL::bigint, relative_start bigint DEFAULT NULL::bigint)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
  cur_pos bigint;
  abs_offset bigint;
BEGIN
  if absolute_start is null and relative_start is null then
    pkg_util.file_seek(file, absolute_start);
    return;
  end if;
  if absolute_start is not null then
    pkg_util.file_seek(file, absolute_start);
    return;
  end if;
  if relative_start is not null then
    cur_pos := pkg_util.file_getpos(file);
    if relative_start > 9223372036854775807 - cur_pos then
        raise exception 'Absolute start beyond bigint range.';
    end if;
    abs_offset := cur_pos + relative_start;

    if abs_offset <= 0 then
        abs_offset := 0;
    end if;

    pkg_util.file_seek(file, abs_offset);
  end if;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.write(file integer, buffer text)
 RETURNS boolean
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  RETURN pkg_util.file_write(file, buffer);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_file.write_line(file integer, buffer text, flush boolean DEFAULT false)
 RETURNS boolean
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
  has_write bool;
BEGIN
	has_write := false;
	if flush = false then
		RETURN pkg_util.file_writeline(file, buffer);
	else
		has_write := pkg_util.file_writeline(file, buffer);
		if has_write = true then
			PERFORM pkg_util.file_flush(file);
		end if;
	end if;
	RETURN has_write;
END;
$function$;

-- DROP SCHEMA dbe_lob;

CREATE SCHEMA dbe_lob AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_lob.append(INOUT blob_obj blob, source_obj blob)
 RETURNS blob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    blob_obj := PKG_UTIL.lob_append(blob_obj::blob, source_obj::blob, null);
    return blob_obj;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.append(INOUT clob_obj clob, source_obj clob)
 RETURNS clob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    clob_obj := PKG_UTIL.lob_append(clob_obj::clob, source_obj::clob, null);
    return clob_obj;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.close(blob)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.close(file integer)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    PERFORM pkg_util.file_close(file);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.close(clob)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.compare(clob_obj1 clob, clob_obj2 clob, amount integer DEFAULT 1073741771, offset1 integer DEFAULT 1, offset2 integer DEFAULT 1)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_compare(clob_obj1, clob_obj2, amount, offset1, offset2/*, false*/);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.compare(blob_obj1 blob, blob_obj2 blob, amount integer DEFAULT 1073741771, offset1 integer DEFAULT 1, offset2 integer DEFAULT 1)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_compare(blob_obj1, blob_obj2, amount, offset1, offset2/*, true*/);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.converttoblob(dest_blob blob, src_clob clob, amount integer DEFAULT 32767, dest_offset integer DEFAULT 1, src_offset integer DEFAULT 1)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_converttoblob(dest_blob, src_clob, amount, dest_offset, src_offset);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.converttoclob(dest_clob clob, src_blob blob, amount integer DEFAULT 32767, dest_offset integer DEFAULT 1, src_offset integer DEFAULT 1)
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_converttoclob(dest_clob, src_blob, amount, dest_offset, src_offset);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.copy(INOUT blob, blob, integer, integer DEFAULT 1, integer DEFAULT 1)
 RETURNS blob
 LANGUAGE c
 STRICT NOT FENCED SHIPPABLE
AS '$libdir/packages', $function$lob_copy$function$;

CREATE OR REPLACE PROCEDURE dbe_lob.create_temporary(
	inout clob,
	in boolean,
	in int default 1
)
 SHIPPABLE PACKAGE
AS  DECLARE 
BEGIN
END;
/;

CREATE OR REPLACE PROCEDURE dbe_lob.create_temporary(
	inout blob,
	in boolean,
	in int default 10
)
 SHIPPABLE PACKAGE
AS  DECLARE 
BEGIN
END;
/;

CREATE OR REPLACE PROCEDURE dbe_lob.erase(
    INOUT blob_obj blob, /*obj*/
    inout amount integer, /*amount*/
    IN off_set integer default 1 /*offset*/
)
 SHIPPABLE
AS 
DECLARE
    type r1 is record(result_blob blob, result_amount integer);
    result r1;
BEGIN
    result := PKG_UTIL.lob_reset(blob_obj, amount, off_set, 0);
    blob_obj := result.result_blob;
    amount := result.result_amount;
END;
/;

CREATE OR REPLACE FUNCTION dbe_lob.fileclose(file integer)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    PERFORM pkg_util.file_close(file);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.fileopen(bfile dbe_lob.bfile, open_mode text)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return DBE_FILE.open(bfile.directory, bfile.filename, open_mode);
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_lob.freetemporary(
	inout clob
)
 SHIPPABLE PACKAGE
AS  DECLARE 
BEGIN
END;
/;

CREATE OR REPLACE PROCEDURE dbe_lob.freetemporary(
	inout blob
)
 SHIPPABLE PACKAGE
AS  DECLARE 
BEGIN
END;
/;

CREATE OR REPLACE FUNCTION dbe_lob.get_length(clob_obj blob)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_get_length(clob_obj);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.get_length(blob_obj clob)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_get_length(blob_obj);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.getchunksize(lob_loc blob)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return 1;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.loadblobfromfile(dest_lob blob, src_file integer, amount integer, dest_offset integer, src_offset integer)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    file_context text;
	temp_clob clob;
BEGIN
	pkg_util.file_read(src_file, file_context);
	temp_clob := PKG_UTIL.lob_read(file_context, amount, dest_offset, 2);
	return PKG_UTIL.lob_texttoraw(temp_clob);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.loadclobfromfile(dest_lob clob, src_file integer, amount integer, dest_offset integer, src_offset integer)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    file_context text;
BEGIN
	pkg_util.file_read(src_file, file_context);
	return PKG_UTIL.lob_read(file_context, amount, dest_offset, 2);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.loadfromfile(dest_lob blob, src_file integer, amount integer, dest_offset integer, src_offset integer)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    file_context text;
	temp_clob clob;
BEGIN
	pkg_util.file_read(src_file, file_context);
	temp_clob := PKG_UTIL.lob_read(file_context, amount, dest_offset, 2);
	return PKG_UTIL.lob_texttoraw(temp_clob);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.match(clob_obj1 clob, clob_obj2 character varying, beg_index integer DEFAULT 1, occur_index integer DEFAULT 1)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$lob_match$function$;

CREATE OR REPLACE FUNCTION dbe_lob.match(blob_obj1 blob, blob_obj2 raw, beg_index integer DEFAULT 1, occur_index integer DEFAULT 1)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$lob_match$function$;

CREATE OR REPLACE PROCEDURE dbe_lob.open(
	inout blob
)
 SHIPPABLE PACKAGE
AS  DECLARE 
BEGIN
END;
/;

CREATE OR REPLACE PROCEDURE dbe_lob.open(
	inout clob
)
 SHIPPABLE PACKAGE
AS  DECLARE 
BEGIN
END;
/;

CREATE OR REPLACE FUNCTION dbe_lob.open(bfile dbe_lob.bfile, open_mode text DEFAULT 'null'::text)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return DBE_FILE.open(bfile.directory, bfile.filename, open_mode);
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_lob.read(
    IN blob_obj blob, /*obj*/
    IN amount integer, /*amount*/
    IN off_set integer, /*offset*/
    OUT out_put raw
)
 PACKAGE
AS  DECLARE 
BEGIN
    out_put:=PKG_UTIL.lob_read(blob_obj, amount, off_set, 0);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_lob.read(
    IN clob_obj clob, /*obj*/
    IN amount integer, /*amount*/
    IN off_set integer, /*offset*/
    OUT out_put varchar2
)
 PACKAGE
AS  DECLARE 
BEGIN
    out_put:=PKG_UTIL.lob_read(clob_obj, amount, off_set, 0);
END;
/;

CREATE OR REPLACE FUNCTION dbe_lob.strip(INOUT lob_loc clob, newlen integer)
 RETURNS clob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    lob_loc := PKG_UTIL.lob_read(lob_loc, newlen, 1, 1);
    return lob_loc;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.strip(INOUT lob_loc blob, newlen integer)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    lob_loc := PKG_UTIL.lob_read(lob_loc, newlen, 1, 1);
    return lob_loc;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.substr(lob_loc blob, amount integer DEFAULT 32767, off_set integer DEFAULT 1)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_read(lob_loc, amount, off_set, 2);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.substr(lob_loc clob, amount integer DEFAULT 32767, off_set integer DEFAULT 1)
 RETURNS character varying
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_read(lob_loc, amount, off_set, 2);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.write(INOUT clob_obj clob, amount integer, off_set integer, source character varying)
 RETURNS clob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    clob_obj := PKG_UTIL.lob_write(clob_obj, source, amount, off_set);
    return clob_obj;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.write(INOUT blob_obj blob, amount integer, off_set integer, source raw)
 RETURNS blob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    blob_obj := PKG_UTIL.lob_write(blob_obj, source, amount, off_set);
    return blob_obj;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.write_append(INOUT clob_obj clob, amount integer, source_obj character varying)
 RETURNS clob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    clob_obj := PKG_UTIL.lob_append(clob_obj::clob, source_obj::clob, amount);
    return clob_obj;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_lob.write_append(INOUT blob_obj blob, amount integer, source_obj raw)
 RETURNS blob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    blob_obj := PKG_UTIL.lob_append(blob_obj::blob, source_obj::blob, amount);
    return blob_obj;
END;
$function$;

-- DROP SCHEMA dbe_match;

CREATE SCHEMA dbe_match AUTHORIZATION "rdsAdmin";
CREATE OR REPLACE FUNCTION dbe_match.edit_distance_similarity(str1 text, str2 text)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return pkg_util.match_edit_distance_similarity(str1, str2);
END;
$function$;

-- DROP SCHEMA dbe_output;

CREATE SCHEMA dbe_output AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_output.print(format text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    PKG_UTIL.io_print(format, false);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_output.print_line(format text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    PKG_UTIL.io_print(format, true);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_output.set_buffer_size(integer DEFAULT 20000)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_buffer_size$function$;

-- DROP SCHEMA dbe_random;

CREATE SCHEMA dbe_random AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_random.get_value(min numeric DEFAULT 0, max numeric DEFAULT 1)
 RETURNS numeric
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
  value numeric;
BEGIN
  value := pkg_util.random_get_value();
  value := value * (max - min) + min;
  RETURN value;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_random.set_seed(seed integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  RETURN pkg_util.random_set_seed(seed);
END;
$function$;

-- DROP SCHEMA dbe_raw;

CREATE SCHEMA dbe_raw AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_raw.bit_or(str1 text, str2 text)
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$bit_or_text$function$;

CREATE OR REPLACE FUNCTION dbe_raw.cast_from_binary_integer_to_raw(value integer, endianess integer DEFAULT 1)
 RETURNS raw
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$cast_from_binary_integer_to_raw$function$;

CREATE OR REPLACE FUNCTION dbe_raw.cast_from_raw_to_binary_integer(value raw, endianess integer DEFAULT 1)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$cast_raw_to_binary_integer$function$;

CREATE OR REPLACE FUNCTION dbe_raw.cast_from_varchar2_to_raw(str character varying)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_UTIL.raw_cast_from_varchar2(str);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_raw.cast_to_varchar2(str raw)
 RETURNS character varying
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_UTIL.raw_cast_to_varchar2(str);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_raw.get_length(value raw)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_UTIL.raw_get_length(value);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_raw.substr(lob_loc clob, off_set integer DEFAULT 1, amount integer DEFAULT 32767)
 RETURNS character varying
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_read(lob_loc, amount, off_set, 2);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_raw.substr(lob_loc blob, off_set integer DEFAULT 1, amount integer DEFAULT 32767)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $function$
BEGIN
    return PKG_UTIL.lob_read(lob_loc, amount, off_set, 2);
END;
$function$;

-- DROP SCHEMA dbe_scheduler;

CREATE SCHEMA dbe_scheduler AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_scheduler.create_credential(credential_name text, username text, password text DEFAULT NULL::text, database_role text DEFAULT NULL::text, windows_domain text DEFAULT NULL::text, comments text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$create_credential$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.create_job(job_name text, program_name text, schedule_name text, job_class text DEFAULT 'DEFAULT_JOB_CLASS'::text, enabled boolean DEFAULT false, auto_drop boolean DEFAULT true, comments text DEFAULT NULL::text, job_style text DEFAULT 'REGULAR'::text, credential_name text DEFAULT NULL::text, destination_name text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$create_job_2$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.create_job(job_name text, job_type text, job_action text, number_of_arguments integer DEFAULT 0, start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, repeat_interval text DEFAULT NULL::text, end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, job_class text DEFAULT 'DEFAULT_JOB_CLASS'::text, enabled boolean DEFAULT false, auto_drop boolean DEFAULT true, comments text DEFAULT NULL::text, credential_name text DEFAULT NULL::text, destination_name text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$create_job_1$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.create_job(job_name text, schedule_name text, job_type text, job_action text, number_of_arguments integer DEFAULT 0, job_class text DEFAULT 'DEFAULT_JOB_CLASS'::text, enabled boolean DEFAULT false, auto_drop boolean DEFAULT true, comments text DEFAULT NULL::text, credential_name text DEFAULT NULL::text, destination_name text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$create_job_4$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.create_job(job_name text, program_name text, start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, repeat_interval text DEFAULT NULL::text, end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, job_class text DEFAULT 'DEFAULT_JOB_CLASS'::text, enabled boolean DEFAULT false, auto_drop boolean DEFAULT true, comments text DEFAULT NULL::text, job_style text DEFAULT 'REGULAR'::text, credential_name text DEFAULT NULL::text, destination_name text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$create_job_3$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.create_job_class(job_class_name text, resource_consumer_group text DEFAULT NULL::text, service text DEFAULT NULL::text, logging_level integer DEFAULT 0, log_history integer DEFAULT NULL::integer, comments text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$create_job_class$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.create_program(program_name text, program_type text, program_action text, number_of_arguments integer DEFAULT 0, enabled boolean DEFAULT false, comments text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$create_program$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.create_schedule(schedule_name text, start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, repeat_interval text, end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, comments text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$create_schedule$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.define_program_argument(program_name text, argument_position integer, argument_name text DEFAULT NULL::text, argument_type text, default_value text, out_argument boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$define_program_argument_2$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.define_program_argument(program_name text, argument_position integer, argument_name text DEFAULT NULL::text, argument_type text, out_argument boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$define_program_argument_1$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.disable(name text, force boolean DEFAULT false, commit_semantics text DEFAULT 'STOP_ON_FIRST_ERROR'::text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    name_list text[];
BEGIN
    if pg_catalog.upper(commit_semantics) not in ('STOP_ON_FIRST_ERROR', 'ABSORB_ERRORS', 'TRANSACTIONAL') then
        raise exception 'commit_semantics must be in (STOP_ON_FIRST_ERROR, ABSORB_ERRORS, TRANSACTIONAL).';
    end if;

    name_list := pg_catalog.string_to_array(name, ',', NULL);
    for i in 1 .. name_list.count loop
        name_list[i] := pg_catalog.replace(name_list[i], ' ', '');
        BEGIN
            DBE_SCHEDULER.disable_single(name_list[i], force);
            EXCEPTION WHEN others THEN
                if pg_catalog.upper(commit_semantics) = 'STOP_ON_FIRST_ERROR' then
                    raise notice '%', SQLERRM;
                    exit;
                else
                    if pg_catalog.upper(commit_semantics) = 'ABSORB_ERRORS' then
                        raise notice '%', SQLERRM;
                    else
                        raise exception '%', SQLERRM;
                    end if;
                end if;
        END;
    end loop;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.disable_single(name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$disable_single$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_credential(credential_name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$drop_credential$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_job(job_name text, force boolean DEFAULT false, defer boolean DEFAULT false, commit_semantics text DEFAULT 'STOP_ON_FIRST_ERROR'::text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    name_list text[];
BEGIN
    if pg_catalog.upper(commit_semantics) not in ('STOP_ON_FIRST_ERROR', 'ABSORB_ERRORS', 'TRANSACTIONAL') then
        raise exception 'commit_semantics must be in (STOP_ON_FIRST_ERROR, ABSORB_ERRORS, TRANSACTIONAL).';
    end if;

    name_list := pg_catalog.string_to_array(job_name, ',', NULL);
    for i in 1 .. name_list.count loop
        name_list[i] := pg_catalog.replace(name_list[i], ' ', '');
        BEGIN
            DBE_SCHEDULER.drop_single_job(name_list[i], force, defer);
            EXCEPTION WHEN others THEN
                if pg_catalog.upper(commit_semantics) = 'STOP_ON_FIRST_ERROR' then
                    raise notice '%', SQLERRM;
                    exit;
                else
                    if pg_catalog.upper(commit_semantics) = 'ABSORB_ERRORS' then
                        raise notice '%', SQLERRM;
                    else
                        raise exception '%', SQLERRM;
                    end if;
                end if;
        END;
    end loop;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_job_class(job_class_name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    name_list text[];
BEGIN
    name_list := pg_catalog.string_to_array(job_class_name, ',', NULL);
    for i in 1 .. name_list.count loop
        name_list[i] := pg_catalog.replace(name_list[i], ' ', '');
        DBE_SCHEDULER.drop_single_job_class(name_list[i], force);
    end loop;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_program(program_name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    name_list text[];
BEGIN
    name_list := pg_catalog.string_to_array(program_name, ',', NULL);
    for i in 1 .. name_list.count loop
        name_list[i] := pg_catalog.replace(name_list[i], ' ', '');
        DBE_SCHEDULER.drop_single_program(name_list[i], force);
    end loop;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_schedule(schedule_name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    name_list text[];
BEGIN
    name_list := pg_catalog.string_to_array(schedule_name, ',', NULL);
    for i in 1 .. name_list.count loop
        name_list[i] := pg_catalog.replace(name_list[i], ' ', '');
        DBE_SCHEDULER.drop_single_schedule(name_list[i], force);
    end loop;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_single_job(job_name text, force boolean DEFAULT false, defer boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$drop_single_job$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_single_job_class(job_class_name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$drop_single_job_class$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_single_program(program_name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$drop_single_program$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.drop_single_schedule(schedule_name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$drop_single_schedule$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.enable(name text, commit_semantics text DEFAULT 'STOP_ON_FIRST_ERROR'::text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    name_list text[];
BEGIN

    if pg_catalog.upper(commit_semantics) not in ('STOP_ON_FIRST_ERROR', 'ABSORB_ERRORS', 'TRANSACTIONAL') then
        raise exception 'commit_semantics must be in (STOP_ON_FIRST_ERROR, ABSORB_ERRORS, TRANSACTIONAL).';
    end if;

    name_list := pg_catalog.string_to_array(name, ',', NULL);
    for i in 1 .. name_list.count loop
        name_list[i] := pg_catalog.replace(name_list[i], ' ', '');
        BEGIN
            DBE_SCHEDULER.enable_single(name_list[i]);
            EXCEPTION WHEN others THEN
                if pg_catalog.upper(commit_semantics) = 'STOP_ON_FIRST_ERROR' then
                    raise notice '%', SQLERRM;
                    exit;
                else
                    if pg_catalog.upper(commit_semantics) = 'ABSORB_ERRORS' then
                        raise notice '%', SQLERRM;
                    else
                        raise exception '%', SQLERRM;
                    end if;
                end if;
        END;
    end loop;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.enable_single(name text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$enable_single$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.eval_calendar_string(calendar_string text, start_date timestamp with time zone, return_date_after timestamp with time zone)
 RETURNS timestamp with time zone
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$evaluate_calendar_string$function$;

CREATE OR REPLACE PROCEDURE dbe_scheduler.evaluate_calendar_string(
                                    IN calendar_string text,
                                    IN start_date timestamp with time zone,
                                    IN return_date_after timestamp with time zone,
                                    OUT next_run_date timestamp with time zone
                                    )
AS  DECLARE 
BEGIN
    next_run_date := DBE_SCHEDULER.eval_calendar_string(calendar_string, start_date, return_date_after);
END;
/;

CREATE OR REPLACE FUNCTION dbe_scheduler.generate_job_name(prefix text DEFAULT 'JOB$_'::text)
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    id int;
    job_name text;
BEGIN
    if not exists (select * from pg_class where relname = 'gs_job_name_sequence' and relnamespace = 2200) then
        create sequence public.gs_job_name_sequence increment by 1 minvalue 1 no maxvalue start with 1;
    end if;
    id = pg_catalog.nextval('public.gs_job_name_sequence');
    job_name = pg_catalog.concat(prefix, id);
    return job_name;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.grant_user_authorization(username text, privilege text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$grant_user_authorization$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.revoke_user_authorization(username text, privilege text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$revoke_user_authorization$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.run_backend_job(job_name text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$run_backend_job$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.run_foreground_job(job_name text)
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$run_foreground_job$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.run_job(job_name text, use_current_session boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    res text;
BEGIN
    if use_current_session = false then
        DBE_SCHEDULER.run_backend_job(job_name);
        return null;
    else
        res = DBE_SCHEDULER.run_foreground_job(job_name);
        return res;
    end if;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.set_attribute(name text, attribute text, value boolean)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_attribute_1$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.set_attribute(name text, attribute text, value timestamp without time zone)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_attribute_3$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.set_attribute(name text, attribute text, value timestamp with time zone)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_attribute_4$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.set_attribute(name text, attribute text, value text, value2 text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_attribute_5$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.set_job_argument_value(job_name text, argument_name text, argument_value text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_job_argument_value_2$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.set_job_argument_value(job_name text, argument_position integer, argument_value text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_job_argument_value_1$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.stop_job(job_name text, force boolean DEFAULT false, commit_semantics text DEFAULT 'STOP_ON_FIRST_ERROR'::text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    name_list text[];
BEGIN
    if pg_catalog.upper(commit_semantics) not in ('STOP_ON_FIRST_ERROR', 'ABSORB_ERRORS', 'TRANSACTIONAL') then
        raise exception 'commit_semantics must be in (STOP_ON_FIRST_ERROR, ABSORB_ERRORS, TRANSACTIONAL).';
    end if;
    
    name_list := pg_catalog.string_to_array(job_name, ',', NULL);
    for i in 1 .. name_list.count loop
        name_list[i] := pg_catalog.replace(name_list[i], ' ', '');
        BEGIN
            DBE_SCHEDULER.stop_single_job(job_name, force);
            EXCEPTION WHEN others THEN
                if pg_catalog.upper(commit_semantics) = 'STOP_ON_FIRST_ERROR' then
                    raise notice '%', SQLERRM;
                    exit;
                else
                    if pg_catalog.upper(commit_semantics) = 'ABSORB_ERRORS' then
                        raise notice '%', SQLERRM;
                    else
                        raise exception '%', SQLERRM;
                    end if;
                end if;
        END;
    end loop;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_scheduler.stop_single_job(job_name text, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$stop_single_job$function$;

-- DROP SCHEMA dbe_session;

CREATE SCHEMA dbe_session AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_session.clear_context(namespace text, client_identifier text DEFAULT 'null'::text, attribute text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pkg_util.session_clear_context(namespace, client_identifier, attribute);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_session.search_context(namespace text, attribute text)
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return pkg_util.session_search_context(namespace, attribute);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_session.set_context(namespace text, attribute text, value text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pkg_util.session_set_context(namespace, attribute, value);
END;
$function$;

-- DROP SCHEMA dbe_sql;

CREATE SCHEMA dbe_sql AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_sql.bind_variable(context_id integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    if context_id = '' or context_id is null then
        pg_catalog.report_application_error('In DBE_SQL.bind_variable(context_id), context_id cannot be null.'::text);
    end if;
    PKG_SERVICE.sql_clean_all_contexts();
    pg_catalog.report_application_error('DBE_SQL.bind_variable() is not supported yet.'::text);
    return -1;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.dbe_sql_get_result_char(context_id integer, pos integer)
 RETURNS character
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    c1 char;
BEGIN
    return PKG_SERVICE.sql_get_value(context_id, pos, c1 /*BPCHAROID*/);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.dbe_sql_get_result_long(context_id integer, pos integer)
 RETURNS bigint
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    l1 bigint;
BEGIN
    return PKG_SERVICE.sql_get_value(context_id, pos, l1 /*bigint*/);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.dbe_sql_get_result_raw(context_id integer, pos integer)
 RETURNS raw
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    r1 raw;
BEGIN
    return PKG_SERVICE.sql_get_value(context_id, pos, r1 /*BYTEAOID*/);
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_sql.get_array_result_char(
    IN context_id int, /*context_id*/
    IN pos VARCHAR2,  /*position*/
    INOUT column_value anyarray
)
AS 
DECLARE
    c1 char;
BEGIN
    column_value := PKG_SERVICE.sql_get_array_result(context_id, pos, column_value, c1 /*BPCHAROID*/);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_array_result_int(
    IN context_id int,
    IN pos VARCHAR2,
    INOUT column_value anyarray
)
AS 
DECLARE
    i1 integer;
    col_type2 int[];
BEGIN
    col_type2 := column_value;
    column_value := PKG_SERVICE.sql_get_array_result(context_id, pos, col_type2, i1);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_array_result_raw(
    IN context_id int, /*context_id*/
    IN pos VARCHAR2,  /*position*/
    INOUT column_value anyarray
)
AS 
DECLARE
    r1 bytea;
    col_type3 bytea[];
    r2 raw;
    col_type4 raw[];
    col_type text;
BEGIN
    col_type := pg_catalog.pg_typeof(column_value);
    IF col_type = 'raw[]' OR col_type = 'blob[]' THEN
        column_value := PKG_SERVICE.sql_get_array_result(context_id, pos, col_type4, r2);
    ELSIF col_type = 'bytea[]' THEN
        column_value := PKG_SERVICE.sql_get_array_result(context_id, pos, col_type3, r1);
    ELSE
        pg_catalog.report_application_error('invalid type'); 
    END IF;
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_array_result_text(
    IN context_id int, /*context_id*/
    IN pos VARCHAR2,  /*position*/
    INOUT column_value anyarray
)
AS 
DECLARE
    t1 text;
    col_type1 text[];
BEGIN
    col_type1 := column_value;
    column_value := PKG_SERVICE.sql_get_array_result(context_id, pos, col_type1, t1);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_result(
        IN context_id int,
        IN pos int,
        INOUT column_value anyelement
)
AS 
DECLARE
    col_type text;
    col_type1 text[];
BEGIN
    col_type := pg_catalog.pg_typeof(column_value);
    IF col_type = 'integer[]' OR col_type = 'bigint[]' THEN
        DBE_SQL.get_results_int(context_id, pos, column_value);
    ELSIF col_type = 'text[]' OR col_type = 'clob[]' OR col_type = 'character varying[]' THEN
        DBE_SQL.get_results_text(context_id, pos, column_value);
    ELSIF col_type = 'bytea[]' THEN
        DBE_SQL.get_results_bytea(context_id, pos, column_value);
    ELSIF col_type = 'raw[]' THEN
        DBE_SQL.get_results_raw(context_id, pos, column_value);
    ELSIF col_type = 'character[]' THEN
        DBE_SQL.get_results_char(context_id, pos, column_value);
    ELSIF col_type = 'integer' OR col_type = 'bigint' THEN
        column_value := DBE_SQL.get_result_int(context_id, pos);
    ELSIF col_type = 'text' OR col_type = 'clob' OR col_type = 'character varying' THEN
        column_value := DBE_SQL.get_result_text(context_id, pos);
    ELSIF col_type = 'character' THEN
        column_value := DBE_SQL.get_result_char(context_id, pos, column_value);
    ELSIF col_type = 'raw' OR col_type = 'blob' THEN
        column_value := DBE_SQL.get_result_raw(context_id, pos, column_value);
    ELSIF col_type = 'bytea' THEN
        column_value := DBE_SQL.get_result_bytea(context_id, pos);
    ELSE
        /* report error as default */
        DBE_SQL.get_result_unknown(context_id, pos, col_type);
    END IF;
END;
/;

CREATE OR REPLACE FUNCTION dbe_sql.get_result_bytea(context_id integer, pos integer)
 RETURNS bytea
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    r1 bytea;
BEGIN
    return PKG_SERVICE.sql_get_value(context_id, pos, r1);
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_sql.get_result_char(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT tr char, /*value*/
    INOUT err numeric, /*colmn_error*/
    INOUT actual_length int/*actual_length*/
)
 PACKAGE
AS  DECLARE 	vl text;
BEGIN
	vl := DBE_SQL.dbe_sql_get_result_char(context_id, pos);
	IF (actual_length < pg_catalog.length(vl)) THEN
		tr := pg_catalog.substr(vl, 0, actual_length);
	ELSE
		tr := vl;
	END IF;
	actual_length := pg_catalog.length(tr);
	err := 1;
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_result_char(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT tr char /*value*/
)
 PACKAGE
AS  DECLARE  vl text;
BEGIN
        vl := DBE_SQL.dbe_sql_get_result_char(context_id, pos);
        tr := vl;
END;
/;

CREATE OR REPLACE FUNCTION dbe_sql.get_result_int(context_id integer, pos integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    i1 integer;
BEGIN
    return PKG_SERVICE.sql_get_value(context_id, pos, i1 /*int*/);
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_sql.get_result_long(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    IN lgth int, /*length*/
    IN off_set int, /*offset*/
    INOUT vl text, /*value*/
    INOUT vl_length int /*value_length*/
)
AS 
DECLARE
	tr text;
BEGIN
	tr := DBE_SQL.get_result_text(context_id, pos);
	vl := pg_catalog.substr(tr, off_set, lgth);
	vl_length := pg_catalog.length(vl);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_result_raw(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT tr raw, /*value*/
    INOUT err numeric, /*colmn_error*/
    INOUT actual_length int/*actual_length*/
)
 PACKAGE
AS  DECLARE 	vl raw;
BEGIN
	vl := DBE_SQL.dbe_sql_get_result_raw(context_id, pos);
	IF (actual_length < pg_catalog.length(vl)) THEN
		tr := pg_catalog.substr(vl, 0, actual_length);
	ELSE
		tr := vl;
	END IF;
	actual_length := pg_catalog.length(tr);
	err := 1;
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_result_raw(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT tr raw /*value*/
)
 PACKAGE
AS  DECLARE  vl raw;
BEGIN
        vl := DBE_SQL.dbe_sql_get_result_raw(context_id, pos);
        tr := vl;
END;
/;

CREATE OR REPLACE FUNCTION dbe_sql.get_result_text(context_id integer, pos integer)
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    t1 text;
BEGIN
    return PKG_SERVICE.sql_get_value(context_id, pos, t1 /*text*/);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.get_result_unknown(context_id integer, pos integer, col_type text)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
  PKG_SERVICE.sql_clean_all_contexts();
  if col_type is NULL then
    pg_catalog.report_application_error('invalid input for the third parameter col_type should not be null');
  end if;
  pg_catalog.report_application_error('UnSupport data type for column_value(context: '||context_id||', pos: '||pos||', '||pg_catalog.quote_literal(col_type)||')');
  return -1;
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_sql.get_results(
    IN context_id int,
    IN pos int,
    INOUT column_value anyelement
)
AS 
DECLARE
    col_type text;
    col_type1 text[];
BEGIN
    col_type := pg_catalog.pg_typeof(column_value);
    IF col_type = 'integer[]' OR col_type = 'bigint[]' THEN
        DBE_SQL.get_results_int(context_id, pos, column_value);
    ELSIF col_type = 'text[]' OR col_type = 'clob[]' OR col_type = 'character varying[]' THEN
        DBE_SQL.get_results_text(context_id, pos, column_value);
    ELSIF col_type = 'bytea[]' THEN
        DBE_SQL.get_results_bytea(context_id, pos, column_value);
    ELSIF col_type = 'raw[]' THEN
        DBE_SQL.get_results_raw(context_id, pos, column_value);
    ELSIF col_type = 'character[]' THEN
        DBE_SQL.get_results_char(context_id, pos, column_value);
    ELSIF col_type = 'integer' OR col_type = 'bigint' THEN
        column_value := DBE_SQL.get_result_int(context_id, pos);
    ELSIF col_type = 'text' OR col_type = 'clob' OR col_type = 'character varying' THEN
        column_value := DBE_SQL.get_result_text(context_id, pos);
    ELSIF col_type = 'character' THEN
        column_value := DBE_SQL.get_result_char(context_id, pos, column_value);
    ELSIF col_type = 'raw' OR col_type = 'blob' THEN
        column_value := DBE_SQL.get_result_raw(context_id, pos, column_value);
    ELSIF col_type = 'bytea' THEN
        column_value := DBE_SQL.get_result_bytea(context_id, pos);
    ELSE
        /* report error as default */
        DBE_SQL.get_result_unknown(context_id, pos, col_type);
    END IF;
    
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_results_bytea(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT column_value anyarray
)
AS 
DECLARE
    r1 bytea;
BEGIN
    column_value := DBE_SQL.sql_get_values_c(context_id, pos, column_value, r1 /*BYTEAOID*/);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_results_char(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT column_value anyarray
)
AS 
DECLARE
    c1 char;
BEGIN
    column_value := DBE_SQL.sql_get_values_c(context_id, pos, column_value, c1 /*BPCHAROID*/);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_results_int(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT column_value anyarray
)
AS 
DECLARE
    i1 integer;
    i2 bigint;
    col_type text;
BEGIN
    col_type := pg_catalog.pg_typeof(column_value);
    IF col_type = 'integer[]' THEN
        column_value := DBE_SQL.sql_get_values_c(context_id, pos, column_value, i1);
    ELSIF col_type = 'bigint[]' THEN
	column_value := DBE_SQL.sql_get_values_c(context_id, pos, column_value, i2);
    ELSE 
        DBE_SQL.get_result_unknown(context_id, pos, col_type);
    END IF;
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_results_raw(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT column_value anyarray
)
AS 
DECLARE
    r1 raw;
BEGIN
    column_value := DBE_SQL.sql_get_values_c(context_id, pos, column_value, r1 /*BYTEAOID*/);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_results_text(
    IN context_id int, /*context_id*/
    IN pos int,  /*position*/
    INOUT column_value anyarray
)
AS 
DECLARE
    t1 text;
    t2 character varying;
    t3 clob;
    col_type text;
BEGIN
    col_type := pg_catalog.pg_typeof(column_value);
    IF col_type = 'character varying[]' THEN
        column_value := DBE_SQL.sql_get_values_c(context_id, pos, column_value, t2);
    ELSIF col_type = 'text[]' THEN
        column_value := DBE_SQL.sql_get_values_c(context_id, pos, column_value, t1);
    ELSIF col_type = 'clob[]' THEN
        column_value := DBE_SQL.sql_get_values_c(context_id, pos, column_value, t3);
    ELSE
        pg_catalog.report_application_error('invalid type');
    END IF;
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_variable_result(
        IN context_id int,
        IN pos VARCHAR2,
        INOUT column_value anyelement
)
AS 
DECLARE
    col_type text;
BEGIN
    col_type := pg_catalog.pg_typeof(column_value);
    IF col_type = 'integer' OR col_type = 'bigint' THEN
        DBE_SQL.get_variable_result_int(context_id, pos, column_value);
    ELSIF col_type = 'text' OR col_type = 'clob' OR col_type = 'character varying' THEN
        column_value := DBE_SQL.get_variable_result_text(context_id, pos);
    ELSIF col_type = 'bytea' OR col_type = 'raw' OR col_type = 'blob' THEN
        DBE_SQL.get_variable_result_raw(context_id, pos, column_value);
    ELSIF col_type = 'character' THEN
        column_value := DBE_SQL.get_variable_result_char(context_id, pos);
    ELSIF col_type = 'integer[]' OR col_type = 'bigint[]' THEN
        column_value := DBE_SQL.get_array_result_int(context_id, pos, column_value);
    ELSIF col_type = 'text[]' OR col_type = 'clob[]' OR col_type = 'character varying[]' THEN
        column_value := DBE_SQL.get_array_result_text(context_id, pos, column_value);
    ELSIF col_type = 'bytea[]' OR col_type = 'raw[]' OR col_type = 'blob[]' THEN
        column_value := DBE_SQL.get_array_result_raw(context_id, pos, column_value);
    ELSIF col_type = 'character[]' THEN
        column_value := DBE_SQL.get_array_result_char(context_id, pos, column_value);
    ELSE
       pg_catalog.report_application_error('invalid type'); 
    END IF;
END;
/;

CREATE OR REPLACE FUNCTION dbe_sql.get_variable_result_char(context_id integer, pos character varying)
 RETURNS character
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    t1 char;
BEGIN
    return PKG_SERVICE.sql_get_variable_result(context_id, pos, t1 /*text*/);
END;
$function$;

CREATE OR REPLACE PROCEDURE dbe_sql.get_variable_result_int(
    IN context_id int, /*context_id*/
    IN pos VARCHAR2,  /*position*/
    INOUT value anyelement
)
AS  DECLARE 
BEGIN
    value := PKG_SERVICE.sql_get_variable_result(context_id, pos, value);
END;
/;

CREATE OR REPLACE PROCEDURE dbe_sql.get_variable_result_raw(
    IN context_id int, /*context_id*/
    IN pos VARCHAR2,  /*position*/
    INOUT value anyelement
)
AS 
DECLARE
    t1 bytea;
BEGIN
    value := PKG_SERVICE.sql_get_variable_result(context_id, pos, value);
END;
/;

CREATE OR REPLACE FUNCTION dbe_sql.get_variable_result_text(context_id integer, pos character varying)
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    t1 text;
BEGIN
    return PKG_SERVICE.sql_get_variable_result(context_id, pos, t1 /*text*/);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.is_active(integer)
 RETURNS boolean
 LANGUAGE c
 STABLE NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$is_context_active$function$;

CREATE OR REPLACE FUNCTION dbe_sql.last_row_count(context_id integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    if context_id = '' or context_id is null then
        pg_catalog.report_application_error('In DBE_SQL.last_row_count(context_id), context_id cannot be null.'::text);
    end if;
    PKG_SERVICE.sql_clean_all_contexts();
    pg_catalog.report_application_error('DBE_SQL.last_row_count() is not supported yet.'::text);
    return -1;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.next_row(context_id integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_SERVICE.sql_next_row(context_id);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.register_context()
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_SERVICE.sql_register_context();
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.run_and_next(context_id integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    if context_id = '' or context_id is null then
        pg_catalog.report_application_error('In DBE_SQL.run_and_next(context_id), context_id cannot be null.'::text);
    end if;
    PKG_SERVICE.sql_clean_all_contexts();
    pg_catalog.report_application_error('DBE_SQL.run_and_next() is not supported yet.'::text);
    return -1;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type(context_id integer, pos integer, column_ref anyelement, maxsize integer DEFAULT 1024)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_type text;
BEGIN
    col_type := pg_catalog.pg_typeof(column_ref);
    IF col_type = 'integer' OR col_type = 'bigint' THEN
        DBE_SQL.set_result_type_int(context_id, pos);
    ELSIF col_type = 'text' OR col_type = 'clob' OR col_type = 'character varying' THEN
        DBE_SQL.set_result_type_text(context_id, pos, maxsize);
    ELSIF col_type='raw' OR col_type = 'blob' THEN
        DBE_SQL.set_result_type_raw(context_id, pos, column_ref, maxsize);
    ELSIF col_type='bytea' THEN
        DBE_SQL.set_result_type_bytea(context_id, pos, column_ref, maxsize);
    ELSIF col_type = 'character'  THEN
        DBE_SQL.set_result_type_char(context_id, pos, col_type, maxsize);
    ELSE
        /* report error as default */
        DBE_SQL.set_result_type_unknown(context_id, pos, col_type);
    END IF;
    return 0;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_bytea(context_id integer, pos integer, column_ref bytea, column_size integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_SERVICE.sql_set_result_type(context_id, pos, column_ref, column_size);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_byteas(context_id integer, pos integer, column_ref anyarray, cnt integer, lower_bnd integer, column_size integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_ref bytea;
BEGIN
    return DBE_SQL.sql_set_results_type_c(context_id, pos, column_ref, cnt, lower_bnd, col_ref, column_size);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_char(context_id integer, pos integer, column_ref text, column_size integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_ref_char char;
BEGIN
    return PKG_SERVICE.sql_set_result_type(context_id, pos, col_ref_char, column_size);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_chars(context_id integer, pos integer, column_ref anyarray, cnt integer, lower_bnd integer, column_size integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_ref_char char;
BEGIN
    return DBE_SQL.sql_set_results_type_c(context_id, pos, column_ref, cnt, lower_bnd, col_ref_char, column_size);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_int(context_id integer, pos integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_ref int;
BEGIN
    return PKG_SERVICE.sql_set_result_type(context_id, pos, col_ref, 0);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_ints(context_id integer, pos integer, column_ref anyarray, cnt integer, lower_bnd integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    i1 integer;
    i2 bigint;
    col_type text;
BEGIN
    col_type := pg_catalog.pg_typeof(column_ref);
    IF col_type = 'integer[]' THEN
         return DBE_SQL.sql_set_results_type_c(context_id, pos, column_ref, cnt, lower_bnd, i1, 0);
    ELSIF col_type = 'bigint[]' THEN
        return DBE_SQL.sql_set_results_type_c(context_id, pos, column_ref, cnt, lower_bnd, i2, 0);
    ELSE
        DBE_SQL.get_result_unknown(context_id, pos, col_type);
    END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_long(context_id integer, pos integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return DBE_SQL.set_result_type_text(context_id, pos, 1024 * 1024 * 1024);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_raw(context_id integer, pos integer, column_ref raw, column_size integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_SERVICE.sql_set_result_type(context_id, pos, column_ref, column_size);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_raws(context_id integer, pos integer, column_ref anyarray, cnt integer, lower_bnd integer, column_size integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_ref raw;
BEGIN
    return DBE_SQL.sql_set_results_type_c(context_id, pos, column_ref, cnt, lower_bnd, col_ref, column_size);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_text(context_id integer, pos integer, maxsize integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_ref text;
BEGIN
    return PKG_SERVICE.sql_set_result_type(context_id, pos, col_ref, maxsize);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_texts(context_id integer, pos integer, column_ref anyarray, cnt integer, lower_bnd integer, maxsize integer)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_ref text;
    col_ref1 text[];
    col_ref2 character varying;
    col_ref3 character varying[];
    col_ref4 clob;
    col_ref5 clob[];
    col_type text;
BEGIN
    col_type := pg_catalog.pg_typeof(column_ref);
    IF col_type = 'text[]' THEN
        DBE_SQL.sql_set_results_type_c(context_id, pos, col_ref1, cnt, lower_bnd, col_ref, maxsize);
    ELSIF col_type = 'character varying[]' THEN
        DBE_SQL.sql_set_results_type_c(context_id, pos, col_ref3, cnt, lower_bnd, col_ref2, maxsize);
    ELSIF col_type = 'clob[]' THEN
        DBE_SQL.sql_set_results_type_c(context_id, pos, col_ref5, cnt, lower_bnd, col_ref4, maxsize);
    ELSE
        pg_catalog.report_application_error('invalid type');
    END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_result_type_unknown(context_id integer, pos integer, col_type text)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    coltype_oid int;
BEGIN
    if context_id = '' or context_id is null or pos = '' or pos is null or col_type = '' or col_type is null then
        pg_catalog.report_application_error('null value not allowed.'::text);
    else
        pg_catalog.report_application_error('UnSupport data type for set_result_type(context: '||context_id||', pos: '||pos||', '||pg_catalog.quote_literal(col_type)||')');
    end if;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.set_results_type(context_id integer, pos integer, column_ref anyarray, cnt integer, lower_bnd integer, maxsize integer DEFAULT 1024)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
DECLARE
    col_type text;
BEGIN
    col_type := pg_catalog.pg_typeof(column_ref);
    IF col_type = 'integer[]' OR col_type = 'bigint[]' THEN
        DBE_SQL.set_result_type_ints(context_id, pos, column_ref, cnt, lower_bnd);
    ELSIF col_type = 'text[]' OR col_type = 'clob[]' OR col_type = 'character varying[]' THEN
        DBE_SQL.set_result_type_texts(context_id, pos, column_ref, cnt, lower_bnd, maxsize);
    ELSIF col_type='bytea[]' THEN
        DBE_SQL.set_result_type_byteas(context_id, pos, column_ref, cnt, lower_bnd, maxsize);
    ELSIF col_type='raw[]' THEN
        DBE_SQL.set_result_type_raws(context_id, pos, column_ref, cnt, lower_bnd, maxsize);
    ELSIF col_type = 'character[]'  THEN
        DBE_SQL.set_result_type_chars(context_id, pos, column_ref, cnt, lower_bnd, maxsize);
    ELSE
        /* report error as default */
        DBE_SQL.set_result_type_unknown(context_id, pos, col_type);
    END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_bind_array(context_id integer, query_string text, value anyarray, lower_index integer, higher_index integer)
 RETURNS void
 LANGUAGE c
 STABLE NOT FENCED NOT SHIPPABLE PACKAGE
AS '$libdir/packages', $function$sql_bind_array$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_bind_array(context_id integer, query_string text, value anyarray)
 RETURNS void
 LANGUAGE c
 STABLE NOT FENCED NOT SHIPPABLE PACKAGE
AS '$libdir/packages', $function$sql_bind_array$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_bind_variable(context_id integer, query_string text, language_flag anyelement, out_value_size integer DEFAULT NULL::integer)
 RETURNS void
 LANGUAGE c
 STABLE NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$sql_bind_variable$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_describe_columns(context_id integer, INOUT col_cnt integer, INOUT desc_t dbe_sql._desc_rec[])
 RETURNS record
 LANGUAGE c
 STABLE NOT FENCED SHIPPABLE
AS '$libdir/packages', $function$sql_describe_columns$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_get_values_c(context_id integer, pos integer, INOUT results_type anyarray, result_type anyelement)
 RETURNS anyarray
 LANGUAGE c
 NOT FENCED SHIPPABLE PACKAGE
AS '$libdir/packages', $function$sql_get_values$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_run(integer)
 RETURNS integer
 LANGUAGE c
 STABLE NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$sql_run$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_set_results_type_c(context_id integer, pos integer, column_ref anyarray, cnt integer, lower_bnd integer, col_type anyelement, maxsize integer)
 RETURNS integer
 LANGUAGE c
 STABLE NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$sql_set_results_type$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_set_sql(context_id integer, query_string text, language_flag integer)
 RETURNS boolean
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_SERVICE.sql_set_sql(context_id, query_string, language_flag);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_sql.sql_unregister_context(context_id integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return PKG_SERVICE.sql_unregister_context(context_id);
END;
$function$;

-- DROP SCHEMA dbe_sql_util;

CREATE SCHEMA dbe_sql_util AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_sql_util.create_abort_sql_patch(name, bigint, text DEFAULT NULL::text, boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE internal
 NOT FENCED NOT SHIPPABLE
AS $function$create_abort_patch_by_id$function$;

CREATE OR REPLACE FUNCTION dbe_sql_util.create_hint_sql_patch(name, bigint, text, text DEFAULT NULL::text, boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE internal
 NOT FENCED NOT SHIPPABLE
AS $function$create_sql_patch_by_id_hint$function$;

CREATE OR REPLACE FUNCTION dbe_sql_util.disable_sql_patch(name)
 RETURNS boolean
 LANGUAGE internal
 NOT FENCED NOT SHIPPABLE
AS $function$disable_sql_patch$function$;

CREATE OR REPLACE FUNCTION dbe_sql_util.drop_sql_patch(name)
 RETURNS boolean
 LANGUAGE internal
 NOT FENCED NOT SHIPPABLE
AS $function$drop_sql_patch$function$;

CREATE OR REPLACE FUNCTION dbe_sql_util.enable_sql_patch(name)
 RETURNS boolean
 LANGUAGE internal
 NOT FENCED NOT SHIPPABLE
AS $function$enable_sql_patch$function$;

CREATE OR REPLACE FUNCTION dbe_sql_util.show_sql_patch(patch_name name, OUT unique_sql_id bigint, OUT enable boolean, OUT abort boolean, OUT hint_str text)
 RETURNS SETOF record
 LANGUAGE internal
 STRICT NOT FENCED NOT SHIPPABLE ROWS 1
AS $function$show_sql_patch$function$;

-- DROP SCHEMA dbe_task;

CREATE SCHEMA dbe_task AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_task.cancel(id bigint)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pkg_service.job_cancel(id);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.change(job bigint, what text DEFAULT NULL::text, next_date timestamp without time zone DEFAULT NULL::timestamp without time zone, job_interval text DEFAULT NULL::text, instance integer DEFAULT NULL::integer, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pkg_service.job_update(job, next_date, job_interval, what);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.content(id bigint, content text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    if content = '' or content is null then
        pg_catalog.report_application_error('In dbe_task.content(id, content), content cannot be null.'::text);
    else
        pkg_service.job_update(id, null, null, content);
    end if;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.finish(id bigint, broken boolean, next_time timestamp without time zone DEFAULT "sysdate"())
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pkg_service.job_finish(id, broken, next_time);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.id_submit(id bigint, what text, next_time timestamp without time zone DEFAULT "sysdate"(), interval_time text DEFAULT 'null'::text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
declare
    res_id int;
BEGIN
    pkg_service.job_submit(id, what, next_time, interval_time, res_id);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task."interval"(id bigint, interval_time text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    if interval_time = '' or interval_time is null then
        interval_time := 'null';
    end if;
    pkg_service.job_update(id, null, interval_time, null);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.job_submit(OUT job integer, what text, next_date timestamp without time zone DEFAULT "sysdate"(), job_interval text DEFAULT 'null'::text, no_parse boolean DEFAULT false, instance integer DEFAULT 0, force boolean DEFAULT false)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    job := pkg_service.job_submit(null, what, next_date, job_interval, job);
    RETURN job;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.next_time(id bigint, next_time text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    if next_time = '' or next_time is null then
        pg_catalog.report_application_error('In dbe_task.next_time(id, next_time), next_time cannot be null.'::text);
    else
        pkg_service.job_update(id, next_time, null, null);
    end if;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.run(job bigint, force boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pkg_service.job_finish(job, false, NULL);
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.submit(what text, next_time timestamp without time zone DEFAULT "sysdate"(), interval_time text DEFAULT 'null'::text, OUT id integer)
 RETURNS integer
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    id := pkg_service.job_submit(null, what, next_time, interval_time, id);
    RETURN id;
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_task.update(id bigint, content text, next_time timestamp without time zone, interval_time text)
 RETURNS void
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pkg_service.job_update(id, next_time, interval_time, content);
END;
$function$;

-- DROP SCHEMA dbe_utility;

CREATE SCHEMA dbe_utility AUTHORIZATION "rdsAdmin";

CREATE OR REPLACE FUNCTION dbe_utility.format_call_stack()
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return pkg_util.utility_format_call_stack();
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_utility.format_error_backtrace()
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return pkg_util.utility_format_error_backtrace();
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_utility.format_error_stack()
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return pkg_util.utility_format_error_stack();
END;
$function$;

CREATE OR REPLACE FUNCTION dbe_utility.get_time()
 RETURNS bigint
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    return pkg_util.utility_get_time ();
END;
$function$;


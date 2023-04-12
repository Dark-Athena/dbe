-- DROP SCHEMA mog_pkg_util;

CREATE SCHEMA mog_pkg_util ;


CREATE OR REPLACE FUNCTION mog_pkg_util.app_read_client_info(OUT buffer text)
 RETURNS text
 LANGUAGE plpgsql
 NOT FENCED NOT SHIPPABLE
AS $$
begin 
	select setting into buffer from pg_settings where name ='application_name';
end;
$$;



CREATE OR REPLACE FUNCTION mog_pkg_util.app_set_client_info(str text)
 RETURNS void
 LANGUAGE plpgsql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$
 BEGIN
      execute  'alter session set application_name = '''||str||'''';
 END;
$$;

/*
CREATE OR REPLACE FUNCTION mog_pkg_util.exception_report_error(code integer, log text, flag boolean DEFAULT false)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT NOT FENCED NOT SHIPPABLE
AS $function$
BEGIN
    pg_catalog.report_application_error(log, code);
END;
$function$;
*/
/*
CREATE OR REPLACE FUNCTION mog_pkg_util.file_block_size(file_name text)
 RETURNS bigint
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_block_size$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_close(file integer)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_close$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_close_all()
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_close_all$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_exists(file_name text)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_exists$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_flush(file integer)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_flush$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_getpos(file integer)
 RETURNS bigint
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_getpos$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_is_close(file integer)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_is_close$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_newline(file integer)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_writeline$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_open(file_name text, open_mode text, change_mode text, encoding name)
 RETURNS integer
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_open$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_open(file_name text, open_mode text, change_mode text)
 RETURNS integer
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_open$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_open(file_name text, open_mode text)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_open$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_read(file integer, OUT buffer text, len bigint DEFAULT 1024)
 RETURNS text
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_read$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_read_raw(file integer, length integer DEFAULT NULL::integer)
 RETURNS raw
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_read_raw$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_readline(file integer, OUT buffer text, len integer DEFAULT 1024)
 RETURNS text
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_readline$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_remove(file_name text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_remove$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_rename(src_dir text, src_file_name text, dest_dir text, dest_file_name text, overwrite boolean DEFAULT false)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_rename$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_seek(file integer, start_pos bigint)
 RETURNS void
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_seek$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_set_dirname(dir text)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_set_dirname$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_set_max_line_size(max_line_size integer)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_set_maxline_size$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_size(file_name text)
 RETURNS bigint
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_size$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_write(file integer, buffer text)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_write$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_write_raw(file integer, r raw)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_write_raw$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.file_writeline(file integer, buffer text)
 RETURNS boolean
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_writeline$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.format_write(file integer, format text, arg1 text DEFAULT NULL::text, arg2 text DEFAULT NULL::text, arg3 text DEFAULT NULL::text, arg4 text DEFAULT NULL::text, arg5 text DEFAULT NULL::text, arg6 text DEFAULT NULL::text)
 RETURNS boolean
 LANGUAGE c
 NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$file_format_write$function$;
*/

CREATE OR REPLACE FUNCTION mog_pkg_util.io_print(format text, is_one_line boolean)
 RETURNS void
 LANGUAGE plpgsql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$
begin 
	dbms_output.enable();
	if is_one_line then 
	dbms_output.put_line(format);
    else 
    dbms_output.put(format);
    end if;
end;
$$;


CREATE OR REPLACE FUNCTION mog_pkg_util.lob_append(INOUT clob, clob, integer DEFAULT NULL::integer)
 RETURNS clob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $$
begin 
	if $3 is null then 
	$1:=($1::text||$2::text)::clob;
    else 
    $1:=($1::text||substr($2::text,1,$3))::clob;
    end if;
end;
$$;

CREATE OR REPLACE FUNCTION mog_pkg_util.lob_append(INOUT dest_lob blob, src_lob blob, len integer DEFAULT NULL::integer)
 RETURNS blob
LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $$
begin 
	if $3 is null then 
	$1:=rawout(rawsend($1)||rawsend($2))::text::raw::blob;
    else 
    $1:=rawout(rawsend($1)||substr(rawsend($2),1,$3))::text::raw::blob;
    end if;
end;
$$;

CREATE OR REPLACE FUNCTION mog_pkg_util.lob_compare(lob1 blob, lob2 blob, len integer DEFAULT 1073741771, start_pos1 integer DEFAULT 1, start_pos2 integer DEFAULT 1)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS $$
            DECLARE
            l_result int4 DEFAULT 0;
            l_r1 bytea DEFAULT ''::bytea;
            l_r2 bytea DEFAULT ''::bytea;
            len_1 int4;
            len_2 int4;
            lob1_bytea bytea;
            lob2_bytea bytea;
            begin
            lob1_bytea:=substr(rawsend(lob1),start_pos1,least(len,pg_catalog.length(rawsend(lob1))-start_pos1+1));
            lob2_bytea:=substr(rawsend(lob2),start_pos2,least(len,pg_catalog.length(rawsend(lob2))-start_pos2+1));

            len_1:=pg_catalog.length(lob1_bytea);
            len_2:=pg_catalog.length(lob2_bytea);

            if len_1<len_2 then
            return -1;
            elsif len_1>len_2 then
            return 1;
            end if;

            for i in 1..greatest(len_1,len_2)   LOOP
            l_r1:=pg_catalog.substr(lob1_bytea , i , 1);
            l_r2:=pg_catalog.substr(lob2_bytea , i , 1);
            if l_r1!=l_r2 THEN
            if l_r1>l_r2 then
            l_result:=1;
            else
            l_result:=-1;
            end if;
            EXIT;
            end if;
            end loop;
            return l_result;
            end;
            $$;
           

CREATE OR REPLACE FUNCTION mog_pkg_util.lob_compare(lob1 clob, lob2 clob, len integer DEFAULT 1073741771, start_pos1 integer DEFAULT 1, start_pos2 integer DEFAULT 1)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS $$
DECLARE
            l_result int4 DEFAULT 0;
            l_r1 text DEFAULT ''::text;
            l_r2 text DEFAULT ''::text;
            len_1 int4;
            len_2 int4;
            lob1_text text;
            lob2_text text;
            begin
            lob1_text:=substr(lob1::text,start_pos1,least(len,pg_catalog.length(lob1::text)-start_pos1+1));
            lob2_text:=substr(lob2::text,start_pos2,least(len,pg_catalog.length(lob2::text)-start_pos2+1));

            len_1:=pg_catalog.length(lob1_text);
            len_2:=pg_catalog.length(lob2_text);

            if len_1<len_2 then
            return -1;
            elsif len_1>len_2 then
            return 1;
            end if;

            for i in 1..greatest(len_1,len_2)   LOOP
            l_r1:=pg_catalog.substr(lob1_text , i , 1);
            l_r2:=pg_catalog.substr(lob2_text , i , 1);
            if l_r1!=l_r2 THEN
            if l_r1::bytea>l_r2::bytea then
            l_result:=1;
            else
            l_result:=-1;
            end if;
            EXIT;
            end if;
            end loop;
            return l_result;
            end;
            $$;
           
CREATE OR REPLACE FUNCTION mog_pkg_util.lob_converttoblob(inout dest_lob blob, src_clob clob, amount integer, dest_offset integer, src_offset integer)
 RETURNS raw
 LANGUAGE plpgsql
  NOT FENCED NOT SHIPPABLE
AS $$
declare 
            null_bytea raw DEFAULT '00'::raw;
            pad_bytea raw DEFAULT ''::raw;
begin 
	for i in 1..dest_offset-1 LOOP
            pad_bytea:=pad_bytea||null_bytea;
    end loop;
          
	dest_lob:= (pad_bytea||rawtohex((pg_catalog.substr(src_clob::text,src_offset,amount))::text))::blob;
end;
$$;


CREATE OR REPLACE FUNCTION mog_pkg_util.lob_converttoclob(inout dest_lob clob, src_blob blob, amount integer, dest_offset integer, src_offset integer)
 RETURNS text
 LANGUAGE plpgsql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$
declare 
 null_bytea text DEFAULT ''::text;
 pad_bytea raw DEFAULT ' '::text;
begin 
	for i in 1..dest_offset-1 LOOP
            pad_bytea:=pad_bytea||null_bytea;
    end loop;
          
      dest_lob:=(pad_bytea|| convert_from(pg_catalog.substr(rawsend(r),src_offset,amount),(select pg_encoding_to_char(encoding) as encoding from pg_database where datname=current_database())))::clob;
end;
$$;


CREATE OR REPLACE FUNCTION mog_pkg_util.lob_get_length(lob blob)
 RETURNS integer
 LANGUAGE sql
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS $$
            SELECT pg_catalog.length(rawsend(lob))::INT4;
            $$;

CREATE OR REPLACE FUNCTION mog_pkg_util.lob_get_length(lob clob)
 RETURNS integer
 LANGUAGE sql
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS $$
            SELECT pg_catalog.length(lob)::INT4;
            $$;
           
CREATE OR REPLACE FUNCTION mog_pkg_util.lob_match(lob blob, pattern raw, start_pos integer default 1, match_nth integer DEFAULT 1)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS $$
            DECLARE
                pos integer  DEFAULT 0;
                occur_number integer NOT NULL DEFAULT 0;
                temp_str BYTEA;
                beg integer;
                i integer;
                length integer;
                ss_length integer;
                loc bytea;
            BEGIN
            loc:=rawsend(lob);
                IF match_nth <= 0 THEN
                    RAISE 'argument ''%'' is out of range', occur_index
                    USING ERRCODE = '22003';
                END IF;

                IF start_pos > 0 THEN
                    beg := start_pos - 1;
                    FOR i IN 1..match_nth LOOP
                        temp_str := substring(loc FROM beg + 1);
                        pos :=nvl( position(RAWSEND(pattern) IN temp_str),0);
                        IF pos = 0 THEN
                            RETURN 0;
                           elsif pos is null then 
                            RETURN null;
                        END IF;
                        beg := beg + pos;
                    END LOOP;

                    RETURN beg;
                ELSIF start_pos < 0 THEN
                    ss_length := pg_catalog.length(RAWSEND(pattern));
                    length := pg_catalog.length(loc);
                    beg := length + 1 + start_pos;

                    WHILE beg > 0 LOOP
                        temp_str := substring(loc FROM beg FOR ss_length);
                        IF RAWSEND(pattern) = temp_str THEN
                            occur_number := occur_number + 1;
                            IF occur_number = match_nth THEN
                                RETURN beg;
                            END IF;
                        END IF;

                        beg := beg - 1;
                    END LOOP;

                    RETURN 0;
                ELSE
                    RETURN 0;
                END IF;
            END;
            $$ ;
          
CREATE OR REPLACE FUNCTION mog_pkg_util.lob_match(lob clob, pattern text, start_pos integer default 1, match_nth integer DEFAULT 1)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS $$
            DECLARE
                pos integer  DEFAULT 0;
                occur_number integer NOT NULL DEFAULT 0;
                temp_str TEXT;
                beg integer;
                i integer;
                length integer;
                ss_length integer;
                loc text;
            BEGIN
            loc:=lob::TEXT;
                IF match_nth <= 0 THEN
                    RAISE 'argument ''%'' is out of range', occur_index
                    USING ERRCODE = '22003';
                END IF;

                IF start_pos > 0 THEN
                    beg := start_pos - 1;
                    FOR i IN 1..match_nth loop
                        temp_str := substring(loc FROM beg + 1);
                        pos := nvl(position(pattern IN temp_str),0);
                        IF pos = 0 THEN
                            RETURN 0;
                           elsif pos is null then 
                            RETURN null;
                        END IF;
                        beg := beg + pos;
                    END LOOP;

                    RETURN beg;
                ELSIF start_pos < 0 THEN
                    ss_length := char_length(pattern);
                    length := char_length(loc);
                    beg := length + 1 + start_pos;

                    WHILE beg > 0 LOOP
                        temp_str := substring(loc FROM beg FOR ss_length);
                        IF pattern = temp_str THEN
                            occur_number := occur_number + 1;
                            IF occur_number = match_nth THEN
                                RETURN beg;
                            END IF;
                        END IF;

                        beg := beg - 1;
                    END LOOP;

                    RETURN 0;
                ELSE
                    RETURN 0;
                END IF;
            END;
            $$;
           
CREATE OR REPLACE FUNCTION mog_pkg_util.lob_rawtotext(src_lob blob)
 RETURNS text
 LANGUAGE sql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$
 SELECT convert_from(rawsend(src_lob::raw),(select pg_encoding_to_char(encoding) as encoding from pg_database where datname=current_database()));
$$;

CREATE OR REPLACE FUNCTION mog_pkg_util.lob_read(lob blob, len integer, start_pos integer, mode integer)
 RETURNS blob
 LANGUAGE plpgsql
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS $$
DECLARE
            tmp_bytea bytea;
begin 
	if mode=0 then 
            tmp_bytea:=pg_catalog.substr(rawsend(lob),start_pos,len);
            if pg_catalog.length(tmp_bytea)=0 or tmp_bytea is null
            then raise NO_DATA_FOUND;
            end if;
            return rawout(tmp_bytea)::text::raw;
	elsif mode =1 then 
	 return rawout(pg_catalog.substr(rawsend(lob),1,len))::text::raw::blob;
	elsif mode=2 then 
	return rawout(pg_catalog.SUBSTR(rawsend(lob),start_pos,len))::text::raw;
	else 
	raise notice 'invail mode!';
	end if;
end;
$$;


CREATE OR REPLACE FUNCTION mog_pkg_util.lob_read(lob clob, len integer, start_pos integer, mode integer)
 RETURNS clob
 LANGUAGE plpgsql
 STRICT NOT FENCED SHIPPABLE PACKAGE
AS $$

begin 
	if mode=0 then 
     return pg_catalog.substr(lob::text,start_pos,len);
	elsif mode =1 then 
	 return pg_catalog.substr(lob::text,1,newlen)::clob;
	elsif mode=2 then 
	 return pg_catalog.SUBSTR(lob::text,start_pos,len);
	else 
	 raise notice 'invail mode!';
	end if;
end;
$$;


CREATE OR REPLACE FUNCTION mog_pkg_util.lob_reset(INOUT lob blob, INOUT len integer, start_pos integer DEFAULT 1, value integer DEFAULT 0)
 RETURNS record
 LANGUAGE plpgsql
 STRICT NOT FENCED SHIPPABLE
AS $$
DECLARE
            lob_length int4;
            lob_bytea bytea;
            null_bytea bytea DEFAULT '\x00'::bytea;
            pad_bytea bytea DEFAULT '\x'::bytea;
            end_bytea bytea;
            result record;
            begin
            lob_bytea:=rawsend(lob);
            lob_length:=pg_catalog.length(lob_bytea);
            if len<lob_length-start_pos+1 then
            end_bytea:=substr(lob_bytea,start_pos+len+1);
            end if;
            len:=least(len,lob_length-start_pos+1);
            for i in 1..len LOOP
            pad_bytea:=pad_bytea||null_bytea;
            end loop;
            lob:=rawout(pg_catalog.substr(lob_bytea,0,start_pos-1)||pad_bytea||end_bytea)::text::raw;
            end;
$$;



CREATE OR REPLACE FUNCTION mog_pkg_util.lob_texttoraw(src_lob clob)
 RETURNS raw
 LANGUAGE sql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$
SELECT rawtohex(src_lob::text)::raw;
$$;

drop function  mog_pkg_util.lob_write(INOUT dest_lob blob, src_lob character varying, len integer, start_pos integer);

CREATE OR REPLACE FUNCTION mog_pkg_util.lob_write(INOUT dest_lob blob, src_lob raw, len integer, start_pos integer)
 RETURNS blob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $$
DECLARE
            dest_bytea bytea;
            end_bytea bytea DEFAULT '\x'::bytea;
            null_bytea bytea DEFAULT '\x00'::bytea;
            dest_bytea_length int4;
            pad_bytea bytea DEFAULT '\x'::bytea;
            src_offset int default 1::int;
            BEGIN
            dest_bytea:=rawsend(dest_lob);
            dest_bytea_length:=pg_catalog.length(dest_bytea);
            if dest_bytea_length>start_pos+len-1 then
            end_bytea:=substr(dest_bytea,start_pos+len);
            end if;
            if dest_bytea_length<start_pos THEN
            for i in 1..start_pos-dest_bytea_length-1 LOOP
            pad_bytea:=pad_bytea||null_bytea;
            end loop;
            end if;

            dest_lob:=rawout(substr(dest_bytea,1,start_pos-1)||pad_bytea||substr(rawsend(src_lob),src_offset,len)||end_bytea)::text::raw::blob;
            end;
           $$;

CREATE OR REPLACE FUNCTION mog_pkg_util.lob_write(INOUT dest_lob clob, src_lob text, len integer, start_pos integer)
 RETURNS clob
 LANGUAGE plpgsql
 NOT FENCED SHIPPABLE PACKAGE
AS $$
 DECLARE
            dest_text text;
            end_text text DEFAULT ''::text;
            null_text text DEFAULT ' '::text;
            dest_text_length int4;
            pad_text text DEFAULT ''::text;
            src_offset int :=1::int;
            BEGIN
            dest_text:=dest_lob::text;
            dest_text_length:=pg_catalog.length(dest_text);
            if dest_text_length>start_pos+len-1 then
            end_text:=substr(dest_text,start_pos+len);
            end if;
            if dest_text_length<start_pos THEN
            for i in 1..start_pos-dest_text_length-1 LOOP
            pad_text:=pad_text||null_text;
            end loop;
            end if;

            dest_lob:=(substr(dest_text,1,start_pos-1)||pad_text||substr(src_lob::text,src_offset,len)||end_text)::clob;
            end;
           $$;

/*
CREATE OR REPLACE FUNCTION mog_pkg_util.match_edit_distance_similarity(str1 text, str2 text)
 RETURNS integer
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$edit_distance_similarity$function$;
*/

CREATE OR REPLACE FUNCTION mog_pkg_util.random_get_value()
 RETURNS numeric
 LANGUAGE sql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$select random()::numeric;$$;

CREATE OR REPLACE FUNCTION mog_pkg_util.random_set_seed(seed integer)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$ BEGIN
                setseed(seed / power(2,31));
               return seed;
     END;
    $$;


CREATE OR REPLACE FUNCTION mog_pkg_util.raw_cast_from_binary_integer(value integer, endianess integer)
 RETURNS raw
 LANGUAGE plpgsql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$
            DECLARE
            l_result raw DEFAULT ''::raw;
            begin
            if endianess in (1,3) then
            l_result:=lpad(to_char(value,'fmxxxxxxxx'),8,'0')::raw;
            elsif endianess =2 then
            l_result:=utl_raw.reverse(replace(lpad(to_char(value,'fmxxxxxxxx'),8,'0'),' ','0')::raw);
            else
            RAISE  'invaild endianess!';
            end if;
            return l_result;
            end;
            $$;

CREATE OR REPLACE FUNCTION mog_pkg_util.raw_cast_from_varchar2(str character varying)
 RETURNS raw
 LANGUAGE sql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$SELECT rawtohex(str)::raw;$$;

CREATE OR REPLACE FUNCTION mog_pkg_util.raw_cast_to_binary_integer(value raw, endianess integer)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$
            DECLARE
            l_result int4;
            begin
            if endianess in (1,3) then
            l_result:=to_number(value::text,'xxxxxxxx');
            elsif endianess =2 then
            l_result:=to_number(utl_raw.reverse(value)::text,'xxxxxxxx');
            else
            RAISE  'invaild endianess!';
            end if;
            return l_result;
            end;
            $$;

CREATE OR REPLACE FUNCTION mog_pkg_util.raw_cast_to_varchar2(str raw)
 RETURNS character varying
 LANGUAGE sql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$
            SELECT convert_from(rawsend(str),(select pg_encoding_to_char(encoding) as encoding from pg_database where datname=current_database()));
$$;


CREATE OR REPLACE FUNCTION mog_pkg_util.raw_get_length(value raw)
 RETURNS integer
 LANGUAGE sql
 STRICT NOT FENCED NOT SHIPPABLE
AS  $$
            SELECT pg_catalog.length(rawsend(value))::INT4;
            $$;
/*
CREATE OR REPLACE FUNCTION mog_pkg_util.session_clear_context(namespace text, client_identifier text, attribute text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$clear_context$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.session_search_context(namespace text, attribute text)
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$search_context$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.session_set_context(namespace text, attribute text, value text)
 RETURNS void
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$set_context$function$;
*/
/*           
CREATE OR REPLACE FUNCTION mog_pkg_util.utility_format_call_stack()
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$format_call_stack$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.utility_format_error_backtrace()
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$format_error_backtrace$function$;

CREATE OR REPLACE FUNCTION mog_pkg_util.utility_format_error_stack()
 RETURNS text
 LANGUAGE c
 STRICT NOT FENCED NOT SHIPPABLE
AS '$libdir/packages', $function$format_error_stack$function$;
*/
CREATE OR REPLACE FUNCTION mog_pkg_util.utility_get_time()
 RETURNS bigint
 LANGUAGE sql
 STRICT NOT FENCED NOT SHIPPABLE
AS $$select (dbms_utility.get_time())::bigint;$$;

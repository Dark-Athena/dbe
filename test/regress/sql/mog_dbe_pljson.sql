CREATE SCHEMA dbe_PLJSON;

set current_schema=dbe_PLJSON;

/* not used now */
create type pljson_element as 
(
  obj_type number
);

create type pljson_value as  (
  /* 1 = object, 2 = array, 3 = string, 4 = number, 5 = bool, 6 = null */
  typeval number(1), 
  str varchar2(32767),
  /* store 1 as true, 0 as false */
  num number,
  num_double binary_double,
  num_repr_number_p varchar2(1),
  num_repr_double_p varchar2(1),
  /* object or array in here */
  object_or_array pljson_element,

  extended_str clob,
  mapname varchar2(4000),
  mapindx number(32)
);

create type pljson_list as (
  pljson_list_data pljson_value[]
);

create type pljson as (
  pljson_list_data pljson_value[],
  check_for_duplicate number
);

alter type pljson_value add attribute arr pljson_list;
alter type pljson_value add attribute obj pljson;

create or replace package pljson_value as

  function gs_pljson_value() return pljson_value;
  function gs_pljson_value(b boolean) return pljson_value;
  function gs_pljson_value(str varchar2, esc boolean default true) return pljson_value;
  function gs_pljson_value(str clob, esc boolean default true) return pljson_value;
  function gs_pljson_value(num number) return pljson_value;
  function gs_pljson_value(num_double binary_double) return pljson_value;
  function gs_pljson_value(elem pljson_element) return pljson_value;
  function gs_makenull() return pljson_value;

  function gs_pljson_value(arr pljson_list) return pljson_value;
  function gs_pljson_value(obj pljson) return pljson_value;

  function gs_get_type(json_value pljson_value) return varchar2;
  function gs_get_string(json_value pljson_value, max_byte_size number default null, max_char_size number default null) return varchar2;
  procedure gs_get_string_clob(json_value pljson_value, buf inout clob);
  function gs_get_clob(json_value pljson_value) return clob;
  function gs_get_bool(json_value pljson_value) return boolean;
  function gs_get_number(json_value pljson_value) return number;
  function gs_get_double(json_value pljson_value) return binary_double;
  function gs_get_element(json_value pljson_value) return pljson_element;
  function gs_get_null(json_value pljson_value) return varchar2;

  function gs_is_string(json_value pljson_value) return boolean;
  function gs_is_bool(json_value pljson_value) return boolean;
  function gs_is_number(json_value pljson_value) return boolean;
  function gs_is_number_repr_number(json_value pljson_value) return boolean;
  function gs_is_number_repr_double(json_value pljson_value) return boolean;
  function gs_is_object(json_value pljson_value) return boolean;
  function gs_is_array(json_value pljson_value) return boolean;
  function gs_is_null(json_value pljson_value) return boolean;
  
  function gs_value_of(json_value pljson_value, max_byte_size number default null, max_char_size number default null) return varchar2;

  procedure gs_parse_number(json_value inout pljson_value, str varchar2);
  function gs_number_toString(json_value pljson_value) return varchar2;
  function gs_to_char(json_value pljson_value, spaces boolean default true, chars_per_line number default 0) return varchar2;
  procedure gs_to_clob(json_value pljson_value, buf inout clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true);
  procedure gs_print(json_value pljson_value, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null);
  procedure htp(json_value pljson_value, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null);

end pljson_value;
/

create or replace package pljson_list as
 
  function gs_pljson_list() return pljson_list;
  function gs_pljson_list(str varchar2) return pljson_list;
  function gs_pljson_list(str clob) return pljson_list;
  function gs_pljson_list(str blob, charset varchar2 default 'UTF8') return pljson_list;
  function gs_pljson_list(str_array varchar2[]) return pljson_list;
  function gs_pljson_list(num_array number[]) return pljson_list;
  function gs_pljson_list(elem pljson_value) return pljson_list;

  procedure gs_append(json_list inout pljson_list, elem pljson_value, _position integer default null);
  procedure gs_append(json_list inout pljson_list, elem varchar2, _position integer default null);
  procedure gs_append(json_list inout pljson_list, elem clob, _position integer default null);
  procedure gs_append(json_list inout pljson_list, elem number, _position integer default null);
  procedure gs_append(json_list inout pljson_list, elem binary_double, _position integer default null);
  procedure gs_append(json_list inout pljson_list, elem boolean, _position integer default null);
  procedure gs_append(json_list inout pljson_list, elem pljson_list, _position integer default null);

  procedure gs_remove(json_list inout pljson_list, _position integer);
  procedure gs_remove_first(json_list inout pljson_list);
  procedure gs_remove_last(json_list inout pljson_list);

  function gs_count(json_list pljson_list) return number;
  function gs_get(json_list pljson_list, _position integer) return pljson_value;
  function gs_get_string(json_list pljson_list, _position integer) return varchar2;
  function gs_get_clob(json_list pljson_list, _position integer) return clob;
  function gs_get_bool(json_list pljson_list, _position integer) return boolean;
  function gs_get_number(json_list pljson_list, _position integer) return number;
  function gs_get_double(json_list pljson_list, _position integer) return binary_double;
  function gs_get_pljson_list(json_list pljson_list, _position integer) return pljson_list;
  function gs_head(json_list pljson_list) return pljson_value;
  function gs_last(json_list pljson_list) return pljson_value;
  function gs_tail(json_list pljson_list) return pljson_list;

  procedure gs_replace(json_list inout pljson_list, _position integer, elem pljson_value);
  procedure gs_replace(json_list inout pljson_list, _position integer, elem varchar2);
  procedure gs_replace(json_list inout pljson_list, _position integer, elem clob);
  procedure gs_replace(json_list inout pljson_list, _position integer, elem number);
  procedure gs_replace(json_list inout pljson_list, _position integer, elem binary_double);
  procedure gs_replace(json_list inout pljson_list, _position integer, elem boolean);
  procedure gs_replace(json_list inout pljson_list, _position integer, elem pljson_list);

  function gs_to_json_value(json_list pljson_list) return pljson_value;

  function gs_to_char(json_list pljson_list, spaces boolean default true, chars_per_line number default 0) return varchar2;
  procedure gs_to_clob(json_list pljson_list, buf inout clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true);
  procedure gs_print(json_list pljson_list, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null);
  procedure htp(json_list pljson_list, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null);

  function gs_path(json_list pljson_list, json_path varchar2, base number default 1) return pljson_value;
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem pljson_value, base number default 1);
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem varchar2, base number default 1);
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem clob, base number default 1);
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem boolean, base number default 1);
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem number, base number default 1);
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem binary_double, base number default 1);
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem pljson_list, base number default 1);

  procedure gs_path_remove(json_list inout pljson_list, json_path varchar2, base number default 1);
 
end pljson_list;
/

create or replace package pljson as

  function gs_pljson() return pljson;
  function gs_pljson(str varchar2) return pljson;
  function gs_pljson(str clob) return pljson;
  function gs_pljson(str blob, charset varchar2 default 'UTF8') return pljson;
  function gs_pljson(str_array varchar2[]) return pljson;
  function gs_pljson(elem pljson_value) return pljson;
  function gs_pljson(l pljson_list) return pljson;

  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value pljson_value, _position integer default null);
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value varchar2, _position integer default null);
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value clob, _position integer default null);
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value number, _position integer default null);
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value binary_double, _position integer default null);
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value boolean, _position integer default null);
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value pljson, _position integer default null);
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value pljson_list, _position integer default null);

  procedure gs_remove(pj pljson, pair_name varchar2);
  
  function gs_count(pj pljson) return number;
  function gs_get(pj pljson, pair_name varchar2) return pljson_value;
  function gs_get_string(pj pljson, pair_name varchar2) return varchar2;
  function gs_get_clob(pj pljson, pair_name varchar2) return clob;
  function gs_get_bool(pj pljson, pair_name varchar2) return boolean;
  function gs_get_number(pj pljson, pair_name varchar2) return number;
  function gs_get_double(pj pljson, pair_name varchar2) return binary_double;
  function gs_get_pljson(pj pljson, pair_name varchar2) return pljson;
  function gs_get_pljson_list(pj pljson, pair_name varchar2) return pljson_list;
  function gs_get(pj pljson, _position integer) return pljson_value;

  function gs_index_of(pj pljson, pair_name varchar2) return number;
  function gs_exist(pj pljson, pair_name varchar2) return boolean;
  function gs_to_json_value(pj pljson) return pljson_value;
  procedure gs_check_duplicate(pj inout pljson, v_set boolean);
  procedure gs_remove_duplicates(pj inout pljson);

  function gs_to_char(pj pljson, spaces boolean default true, chars_per_line number default 0) return varchar2;
  procedure gs_to_clob(pj pljson, buf inout clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true);
  procedure gs_print(pj pljson, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null);
  procedure htp(pj pljson, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null);
  
  function gs_path(pj pljson, json_path varchar2, base number default 1) return pljson_value;

  procedure gs_path_put(pj inout pljson, json_path varchar2, elem pljson_value, base number default 1);
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem varchar2, base number default 1);
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem clob, base number default 1);
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem boolean, base number default 1);
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem number, base number default 1);
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem binary_double, base number default 1);
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem pljson, base number default 1);
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem pljson_list, base number default 1);

  procedure gs_path_remove(pj inout pljson, json_path varchar2, base number default 1);

  function gs_get_keys(pj pljson) return pljson_list;
  function gs_get_values(pj pljson) return pljson_list;

end pljson;
/

create or replace package pljson_ext as
  
  function gs_parsePath(json_path varchar2, base number default 1) return pljson_list;

  --JSON Path getters
  function gs_get_json_value(obj pljson, v_path varchar2, base number default 1) return pljson_value;
  function gs_get_string(obj pljson, path varchar2, base number default 1) return varchar2;
  function gs_get_bool(obj pljson, path varchar2, base number default 1) return boolean;
  function gs_get_number(obj pljson, path varchar2, base number default 1) return number;
  function gs_get_double(obj pljson, path varchar2, base number default 1) return binary_double;
  function gs_get_json(obj pljson, path varchar2, base number default 1) return pljson;
  function gs_get_json_list(obj pljson, path varchar2, base number default 1) return pljson_list;

  --JSON Path putters
  procedure gs_put(obj inout pljson, path varchar2, elem pljson_value, base number default 1);
  procedure gs_put(obj inout pljson, path varchar2, elem varchar2, base number default 1);
  procedure gs_put(obj inout pljson, path varchar2, elem boolean, base number default 1);
  procedure gs_put(obj inout pljson, path varchar2, elem number, base number default 1);
  procedure gs_put(obj inout pljson, path varchar2, elem binary_double, base number default 1);
  procedure gs_put(obj inout pljson, path varchar2, elem pljson, base number default 1);
  procedure gs_put(obj inout pljson, path varchar2, elem pljson_list, base number default 1);

  procedure gs_remove(obj inout pljson, path varchar2, base number default 1);

  --Pretty print with JSON Path
  --function pp(obj pljson, v_path varchar2) return varchar2;
  procedure gs_pp(obj pljson, v_path varchar2); 
  procedure pp_htp(obj pljson, v_path varchar2);

  -- date function
  format_string varchar2(30) := 'yyyy-mm-dd hh24:mi:ss';
  function gs_is_integer(v pljson_value) return boolean;
  function gs_to_json_value(d date) return pljson_value;
  function gs_is_date(v pljson_value) return boolean;
  function gs_to_date(v pljson_value) return date;
  function gs_to_date2(v pljson_value) return date;
  function gs_get_date(obj pljson, path varchar2, base number default 1) return date;
  procedure gs_put(obj inout pljson, path varchar2, elem date, base number default 1);

  function gs_encodeBase64Blob2Clob(p_blob blob) return clob;
  function gs_decodeBase64Clob2Blob(p_clob clob) return blob;

  function gs_base64(binarydata blob) return pljson_list;
  function gs_base64(l pljson_list) return blob;

  function gs_encode(binarydata blob) return pljson_value;
  function gs_decode(v pljson_value) return blob;

  procedure gs_blob2clob(b blob, c out clob, charset varchar2 default 'UTF8');

end pljson_ext;
/

create type rToken as (
  type_name varchar2(7),
  line integer,
  col integer,
  data varchar2(32767),
  data_overflow clob
);

create type json_src as (
  len number, _offset number, offset_chars number, src varchar2(32767), s_clob clob
);

create or replace package pljson_parser as
/*
create type rToken as (
  type_name varchar2(7),
  line integer,
  col integer,
  data varchar2(32767),
  data_overflow clob
);

create type json_src as (
  len number, _offset number, offset_chars number, src varchar2(32767), s_clob clob
);
*/

/*
  type rToken is record (
    type_name varchar2(7),
    line integer,
    col integer,
    data varchar2(32767),
    data_overflow clob);
  type rToken[] is table of rToken index by integer;
  type json_src is record (len number, _offset number, offset_chars number, src varchar2(32767), s_clob clob);
*/  

  json_strict boolean not null := false;

  -- private
  -- function gs_lengthcc(buf clob) return number;
  -- function gs_prepareVarchar2(buf varchar2) return json_src;
  -- function gs_prepareClob(buf clob) return json_src;
  -- function gs_next_char(indx number, s inout json_src) return varchar2;
  -- function gs_next_char2(indx number, s inout json_src, amount number default 1) return varchar2;
  -- function gs_lexer(jsrc inout json_src) return rToken[];
  -- function gs_parseObj(tokens rToken[], indx inout integer) return pljson;
  -- procedure print_token(t rToken);

  -- public
  function gs_parser(str varchar2) return pljson;
  function gs_parse_list(str varchar2) return pljson_list;
  function gs_parse_any(str varchar2) return pljson_value;
  function gs_parser(str clob) return pljson;
  function gs_parse_list(str clob) return pljson_list;
  function gs_parse_any(str clob) return pljson_value;

  procedure gs_remove_duplicates(obj inout pljson);
  function gs_get_version() return varchar2;

end pljson_parser;
/

create or replace package body pljson_parser as

  decimalpoint varchar2(1) := '.';

  procedure s_error(text varchar2, line number, col number) as
  begin
    raise exception 'JSON Scanner exception';
  end;

  procedure s_error(text varchar2, tok rToken) as
  begin
    raise exception 'JSON Scanner exception';
  end;

  procedure p_error(text varchar2, tok rToken) as
  begin
    raise exception 'JSON Parser exception';
  end;

  -- make token
  function mt(t varchar2, l integer, c integer, d varchar2) return rToken as
    token rToken;
  begin
    token.type_name := t;
    token.line := l;
    token.col := c;
    token.data := d;
    return token;
  end;

  procedure print_token(t rToken) as
  begin
    mog_dbe_output.print_line('Line: '||t.line||' - Column: '||t.col||' - Type: '||t.type_name||' - Content: '||t.data);
  end;

  function gs_lengthcc(buf clob) return number as
    _offset number := 0;
    len number := 0;
    src varchar2(32767);
    src_len number;
  begin
    while true loop
      -- begin
      src := mog_dbe_lob.substr(buf, 4000, _offset+1);
      -- exception
      -- when ucs2_exception then
      --  src := mog_dbe_lob.substr(buf, 3999, offset+1);
      -- end;
      exit when src is null;
      len := len + length(src);
      _offset := _offset + length(src); --length2
    end loop;
    return len;
  end;

  -- procedure update_decimalpoint as
  -- begin
  --   select substr(value, 1, 1)
  --   into decimalpoint
  --   from nls_session_parameters
  --   where parameter = 'NLS_NUMERIC_CHARACTERS';
  -- end;
  function gs_prepareVarchar2(buf varchar2) return json_src as
    temp json_src;
  begin
    temp.s_clob := buf;
    temp.offset_chars := 0;
    temp._offset := 0;
    temp.src := substr(buf, 1, 4000);
    temp.len := length(buf);
    return temp;
  end;

  function gs_prepareClob(buf clob) return json_src as
    temp json_src;
  begin
    temp.s_clob := buf;
    temp.offset_chars := 0;
    temp._offset := 0;
    temp.src := mog_dbe_lob.substr(buf, 4000, temp._offset+1);
    temp.len := gs_lengthcc(buf); --mog_dbe_lob.get_length(buf);
    return temp;
  end;

  procedure gs_updateClob(v_extended inout clob, v_str varchar2) as
  begin
    mog_dbe_lob.write_append(v_extended, length(v_str), v_str);
  end;

  function gs_next_char(indx number, s inout json_src) return varchar2 as
  begin
    
    if (indx > s.len) then 
      return null; 
    end if;

    if (indx > length(s.src) + s.offset_chars) then
      while (indx > length(s.src) + s.offset_chars) loop
        s.offset_chars := s.offset_chars + length(s.src);
        s._offset := s._offset + length(s.src); -- length2
        -- begin exception
        s.src := mog_dbe_lob.substr(s.s_clob, 4000, s._offset+1);
      end loop;
    elsif (indx <= s.offset_chars) then
      s.offset_chars := 0;
      s._offset := 0;
      -- begin exception (substr exception?)
      s.src := mog_dbe_lob.substr(s.s_clob, 4000, s.offset+1);
      while (indx > length(s.src) + s.offset_chars) loop
        s.offset_chars := s.offset_chars + length(s.src);
        s._offset := s._offset + length(s.src); --length2
        s.src := mog_dbe_lob.substr(s.s_clob, 4000, s.offset+1);
      end loop;
    end if;
    
    return substr(s.src, indx-s.offset_chars, 1);
  end;

  function gs_next_char2(indx number, s inout json_src, amount number default 1) return varchar2 as
    buf varchar2(32767) := '';
  begin
    for i in 1..amount loop
      buf := buf || gs_next_char(indx-1+i, s);
    end loop;
    return buf;
  end;

  -- [a-zA-Z]([a-zA-Z0-9])*
  procedure gs_lexName(jsrc inout json_src, tok inout rToken, indx inout integer) as
    varbuf varchar2(32767) := '';
    buf varchar(4);
    num number;
  begin
    buf := gs_next_char(indx, jsrc);
    while (REGEXP_LIKE(buf, '^[[:alnum:]\_]$', 'i')) loop
      varbuf := varbuf || buf;
      indx := indx + 1;
      buf := gs_next_char(indx, jsrc);
      if (buf is null) then
        goto retname;
        --debug('Premature string ending');
      end if;
    end loop;
    <<retname>>
    --could check for reserved keywords here
    --debug(varbuf);
    tok.data := varbuf;
    indx := indx - 1;
  end;

  procedure gs_lexNumber(jsrc inout json_src, tok inout rToken, indx inout integer) as
    numbuf varchar2(4000) := '';
    buf varchar2(4);
    checkLoop boolean;
  begin
    buf := gs_next_char(indx, jsrc);
    if (buf = '-') then numbuf := '-'; indx := indx + 1; end if;
    buf := gs_next_char(indx, jsrc);
    --0 or [1-9]([0-9])*
    if (buf = '0') then
      numbuf := numbuf || '0'; indx := indx + 1;
      buf := gs_next_char(indx, jsrc);
    elsif (buf >= '1' and buf <= '9') then
      numbuf := numbuf || buf; indx := indx + 1;
      --read digits
      buf := gs_next_char(indx, jsrc);
      while (buf >= '0' and buf <= '9') loop
        numbuf := numbuf || buf; indx := indx + 1;
        buf := gs_next_char(indx, jsrc);
      end loop;
    end if;
    --fraction
    if (buf = '.') then
      numbuf := numbuf || buf; indx := indx + 1;
      buf := gs_next_char(indx, jsrc);
      checkLoop := FALSE;
      while (buf >= '0' and buf <= '9') loop
        checkLoop := TRUE;
        numbuf := numbuf || buf; indx := indx + 1;
        buf := gs_next_char(indx, jsrc);
      end loop;
      if (not checkLoop) then
        s_error('Expected: digits in fraction', tok);
      end if;
    end if;
    --exp part
    if (buf in ('e', 'E')) then
      numbuf := numbuf || buf; indx := indx + 1;
      buf := gs_next_char(indx, jsrc);
      if (buf = '+' or buf = '-') then
        numbuf := numbuf || buf; indx := indx + 1;
        buf := gs_next_char(indx, jsrc);
      end if;
      checkLoop := FALSE;
      while (buf >= '0' and buf <= '9') loop
        checkLoop := TRUE;
        numbuf := numbuf || buf; indx := indx + 1;
        buf := gs_next_char(indx, jsrc);
      end loop;
      if (not checkLoop) then
        s_error('Expected: digits in exp', tok);
      end if;
    end if;

    tok.data := numbuf;
  end;

  procedure gs_lexString(jsrc inout json_src, tok inout rToken, indx inout integer, endChar char) as
    v_extended clob := null; 
    v_count number := 0;
    varbuf varchar2(32767) := '';
    buf varchar(4);
    wrong boolean;
    max_string_chars number := 5000; 
  begin
    indx := indx + 1;
    buf := gs_next_char(indx, jsrc);
    while (buf != endChar) loop
      --clob control
      if (v_count > 8191) then
        if (v_extended is null) then
          mog_dbe_lob.create_temporary(v_extended, true);
        end if;
        gs_updateClob(v_extended, varbuf); --unistr()
        varbuf := ''; 
        v_count := 0;
      end if;
      if (buf = Chr(13) or buf = CHR(9) or buf = CHR(10)) then
        s_error('Control characters not allowed (CHR(9),CHR(10),CHR(13))', tok);
      end if;
      if (buf = '\') then
        --varbuf := varbuf || buf;
        indx := indx + 1;
        buf := gs_next_char(indx, jsrc);
        case
          when buf in ('\') then
            varbuf := varbuf || buf || buf; v_count := v_count + 2;
            indx := indx + 1;
            buf := gs_next_char(indx, jsrc);
          when buf in ('"', '/') then
            varbuf := varbuf || buf; v_count := v_count + 1;
            indx := indx + 1;
            buf := gs_next_char(indx, jsrc);
          when buf = '''' then
            if (json_strict = false) then
              varbuf := varbuf || buf; v_count := v_count + 1;
              indx := indx + 1;
              buf := gs_next_char(indx, jsrc);
            else
              s_error('strictmode - expected: " \ / b f n r t u ', tok);
            end if;
          when buf in ('b', 'f', 'n', 'r', 't') then
            --backspace b = U+0008
            --formfeed  f = U+000C
            --newline   n = U+000A
            --carret    r = U+000D
            --tabulator t = U+0009
            case buf
            when 'b' then varbuf := varbuf || chr(8);
            when 'f' then varbuf := varbuf || chr(12);
            when 'n' then varbuf := varbuf || chr(10);
            when 'r' then varbuf := varbuf || chr(13);
            when 't' then varbuf := varbuf || chr(9);
            end case;
            --varbuf := varbuf || buf;
            v_count := v_count + 1;
            indx := indx + 1;
            buf := gs_next_char(indx, jsrc);
          when buf = 'u' then
            --four hexadecimal chars
            declare
              four varchar2(4);
            begin
              four := gs_next_char2(indx+1, jsrc, 4);
              wrong := FALSE;
              if (upper(substr(four, 1, 1)) not in ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f')) then wrong := TRUE; end if;
              if (upper(substr(four, 2, 1)) not in ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f')) then wrong := TRUE; end if;
              if (upper(substr(four, 3, 1)) not in ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f')) then wrong := TRUE; end if;
              if (upper(substr(four, 4, 1)) not in ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f')) then wrong := TRUE; end if;
              if (wrong) then
                s_error('expected: " \u([0-9][A-F]){4}', tok);
              end if;
              -- varbuf := varbuf || buf || four;
              varbuf := varbuf || '\'||four;--chr(to_number(four,'XXXX'));
              v_count := v_count + 5;
              indx := indx + 5;
              buf := gs_next_char(indx, jsrc);
            end;
          else
            s_error('expected: " \ / b f n r t u ', tok);
        end case;
      else
        varbuf := varbuf || buf; 
        v_count := v_count + 1;
        indx := indx + 1;
        buf := gs_next_char(indx, jsrc);
      end if;
    end loop;

    if (buf is null) then
      s_error('string ending not found', tok);
    end if;

    if (v_extended is not null) then
      gs_updateClob(v_extended, varbuf);
      tok.data_overflow := v_extended;
      tok.data := mog_pkg_UTIL.lob_read(v_extended, max_string_chars, 1, 0);
    else
      tok.data := varbuf;
    end if;
  end;

  --function gs_lexer(jsrc inout json_src) return rToken[] as
  procedure gs_lexer(jsrc inout json_src, tokens out rToken[]) as
  --  tokens rToken[];
    indx integer := 1;
    tok_indx integer := 1;
    buf varchar2(4);
    lin_no number := 1;
    col_no number := 0;
  begin
    while (indx <= jsrc.len) loop
      --read into buf
      buf := gs_next_char(indx, jsrc);
      col_no := col_no + 1;
      --convert to switch case
      case
        when buf = '{' then tokens[tok_indx] := mt('{', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = '}' then tokens[tok_indx] := mt('}', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = ',' then tokens[tok_indx] := mt(',', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = ':' then tokens[tok_indx] := mt(':', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = '[' then tokens[tok_indx] := mt('[', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = ']' then tokens[tok_indx] := mt(']', lin_no, col_no, null); tok_indx := tok_indx + 1;
        when buf = 't' then
          if (gs_next_char2(indx, jsrc, 4) != 'true') then
            if (json_strict = false and REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i')) then
              tokens[tok_indx] := mt('STRING', lin_no, col_no, null);
              gs_lexName(jsrc, tokens[tok_indx], indx);
              col_no := col_no + length(tokens[tok_indx].data) + 1;
              tok_indx := tok_indx + 1;
            else
              s_error('Expected: ''true''', lin_no, col_no);
            end if;
          else
            tokens[tok_indx] := mt('TRUE', lin_no, col_no, null); tok_indx := tok_indx + 1;
            indx := indx + 3;
            col_no := col_no + 3;
          end if;
        when buf = 'n' then
          if (gs_next_char2(indx, jsrc, 4) != 'null') then
            if (json_strict = false and REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i')) then
              tokens[tok_indx] := mt('STRING', lin_no, col_no, null);
              gs_lexName(jsrc, tokens[tok_indx], indx);
              col_no := col_no + length(tokens[tok_indx].data) + 1;
              tok_indx := tok_indx + 1;
            else
              s_error('Expected: ''null''', lin_no, col_no);
            end if;
          else
            tokens[tok_indx] := mt('NULL', lin_no, col_no, null); tok_indx := tok_indx + 1;
            indx := indx + 3;
            col_no := col_no + 3;
          end if;
        when buf = 'f' then
          if (gs_next_char2(indx, jsrc, 5) != 'false') then
            if (json_strict = false and REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i')) then
              tokens[tok_indx] := mt('STRING', lin_no, col_no, null);
              gs_lexName(jsrc, tokens[tok_indx], indx);
              col_no := col_no + length(tokens[tok_indx].data) + 1;
              tok_indx := tok_indx + 1;
            else
              s_error('Expected: ''false''', lin_no, col_no);
            end if;
          else
            tokens[tok_indx] := mt('FALSE', lin_no, col_no, null); tok_indx := tok_indx + 1;
            indx := indx + 4;
            col_no := col_no + 4;
          end if;
        /* -- 9 = TAB, 10 = \n, 13 = \r (Linux = \n, Windows = \r\n, Mac = \r */
        when (buf = Chr(10)) then --linux newlines
          lin_no := lin_no + 1;
          col_no := 0;
        when (buf = Chr(13)) then --Windows or Mac way
          lin_no := lin_no + 1;
          col_no := 0;
          if (jsrc.len >= indx+1) then -- better safe than sorry
            buf := gs_next_char(indx+1, jsrc);
            if (buf = Chr(10)) then --\r\n
              indx := indx + 1;
            end if;
          end if;
        when (buf = CHR(9)) then 
          null; --tabbing
        when (buf in ('-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')) then --number
          tokens[tok_indx] := mt('NUMBER', lin_no, col_no, null);
          gs_lexNumber(jsrc, tokens[tok_indx], indx);
          indx := indx - 1;
          col_no := col_no + length(tokens[tok_indx].data);
          tok_indx := tok_indx + 1;
        when buf = '"' then --string
          tokens[tok_indx] := mt('STRING', lin_no, col_no, null);
          -- len number, _offset number, offset_chars number, src varchar2(32767), s_clob clob
          -- mog_dbe_output.print_line('len: '||jsrc.len||' - offset: '||jsrc._offset||' - offset_chars: '||jsrc.offset_chars||' - src: '||jsrc.src);
          gs_lexString(jsrc, tokens[tok_indx], indx, '"');
          -- mog_dbe_output.print_line('len: '||jsrc.len||' - offset: '||jsrc._offset||' - offset_chars: '||jsrc.offset_chars||' - src: '||jsrc.src);
          col_no := col_no + length(tokens[tok_indx].data) + 1;
          tok_indx := tok_indx + 1;
        when buf = '''' and json_strict = false then --string
          tokens[tok_indx] := mt('STRING', lin_no, col_no, null);
          gs_lexString(jsrc, tokens[tok_indx], indx, '''');
          col_no := col_no + length(tokens[tok_indx].data) + 1; --hovsa her
          tok_indx := tok_indx + 1;
        when json_strict = false and REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i') then
          tokens[tok_indx] := mt('STRING', lin_no, col_no, null);
          gs_lexName(jsrc, tokens[tok_indx], indx);
          if (tokens[tok_indx].data_overflow is not null) then
            col_no := col_no + gs_lengthcc(tokens[tok_indx].data_overflow) + 1; --mog_dbe_lob.get_length(tokens[tok_indx].data_overflow) + 1;
          else
            col_no := col_no + length(tokens[tok_indx].data) + 1;
          end if;
          tok_indx := tok_indx + 1;
        when json_strict = false and buf||gs_next_char(indx+1, jsrc) = '/*' then --strip comments
          declare
            saveindx number := indx;
            un_esc clob;
          begin
            indx := indx + 1;
            loop
              indx := indx + 1;
              buf := gs_next_char(indx, jsrc)||gs_next_char(indx+1, jsrc);
              exit when buf = '*/';
              exit when buf is null;
            end loop;
        
            if (indx = saveindx+2) then
              -- enter unescaped mode
              -- un_esc := empty_clob();
              mog_dbe_lob.create_temporary(un_esc, true);
              indx := indx + 1;
              loop
                indx := indx + 1;
                buf := gs_next_char(indx, jsrc)||gs_next_char(indx+1, jsrc)||gs_next_char(indx+2, jsrc)||gs_next_char(indx+3, jsrc);
                exit when buf = '/**/';
                if buf is null then
                  s_error('Unexpected sequence /**/ to end unescaped data: '||buf, lin_no, col_no);
                end if;
                buf := gs_next_char(indx, jsrc);
                mog_dbe_lob.write_append(un_esc, length(buf), buf);
              end loop;
              tokens[tok_indx] := mt('ESTRING', lin_no, col_no, null);
              tokens[tok_indx].data_overflow := un_esc;
              col_no := col_no + gs_lengthcc(un_esc) + 1; --mog_dbe_lob.get_length(un_esc) + 1;
              tok_indx := tok_indx + 1;
              indx := indx + 2;
            end if;
            indx := indx + 1;
          end;
        when buf = ' ' then null; --space
        else
          s_error('Unexpected char: '||buf, lin_no, col_no);
      end case;
      indx := indx + 1;
    end loop;

  end;

  /* PARSER FUNCTIONS START */
  procedure gs_parseObj(tokens rToken[], indx inout integer, obj out pljson);
  
  -- parse array
  procedure gs_parseArr(tokens rToken[], indx inout integer, ret_list out pljson_list) as
    e_arr pljson_value[];
    v_count number := 0;
    tok rToken;
    pv pljson_value;
  begin
    --value, value, value ]
    if (indx > tokens.count) then p_error('more elements in array was excepted', tok); end if;
    tok := tokens[indx];
    while (tok.type_name != ']') loop
      v_count := v_count + 1;

      -- print_token(tok);

      case tok.type_name
        when 'TRUE' then e_arr[v_count] := pljson_value.gs_pljson_value(true);
        when 'FALSE' then e_arr[v_count] := pljson_value.gs_pljson_value(false);
        when 'NULL' then e_arr[v_count] := pljson_value.gs_pljson_value();
        when 'STRING' then 
          if tok.data_overflow is not null then
            e_arr[v_count] := pljson_value.gs_pljson_value(tok.data_overflow);
          else
            e_arr[v_count] := pljson_value.gs_pljson_value(tok.data);
          end if;
        when 'ESTRING' then 
          e_arr[v_count] := pljson_value.gs_pljson_value(tok.data_overflow, false);
        when 'NUMBER' then
          pv := pljson_value.gs_pljson_value(0);
          pljson_value.gs_parse_number(pv, replace(tok.data, '.', decimalpoint));
          e_arr[v_count] := pv;
        when '[' then
          declare 
            e_list pljson_list; 
          begin
            indx := indx + 1;
            gs_parseArr(tokens, indx, e_list);
            e_arr[v_count] := pljson_list.gs_to_json_value(e_list);
          end;
        when '{' then
          declare 
            temp_pj pljson; 
          begin
            indx := indx + 1;
            gs_parseObj(tokens, indx, temp_pj);
            e_arr[v_count] := pljson.gs_to_json_value(temp_pj);
          end;
        else
          p_error('Expected a value', tok);
      end case;
      indx := indx + 1;
      if (indx > tokens.count) then p_error('] not found', tok); end if;
      tok := tokens[indx];
      if (tok.type_name = ',') then --advance
        indx := indx + 1;
        if (indx > tokens.count) then p_error('more elements in array was excepted', tok); end if;
        tok := tokens[indx];
        if (tok.type_name = ']') then --premature exit
          p_error('Premature exit in array', tok);
        end if;
      elsif (tok.type_name != ']') then --error
        p_error('Expected , or ]', tok);
      end if;
    end loop;
    ret_list.pljson_list_data := e_arr;
  end;

  -- parse member
  procedure gs_parseMem(tokens rToken[], indx inout integer, mem_name varchar2, mem_indx number, mem out pljson_value) as
    tok rToken;
    pv pljson_value;

  begin
    tok := tokens[indx];

    -- print_token(tok);

    case tok.type_name
      when 'TRUE' then mem := pljson_value.gs_pljson_value(true);
      when 'FALSE' then mem := pljson_value.gs_pljson_value(false);
      when 'NULL' then mem := pljson_value.gs_pljson_value();
      when 'STRING' then
        if tok.data_overflow is not null then
          mem := pljson_value.gs_pljson_value(tok.data_overflow);
        else
          mem := pljson_value.gs_pljson_value(tok.data);
        end if;
      when 'ESTRING' then mem := pljson_value.gs_pljson_value(tok.data_overflow, false);
      when 'NUMBER' then
        pv := pljson_value.gs_pljson_value(0);
        pljson_value.gs_parse_number(pv, replace(tok.data, '.', decimalpoint));
        mem := pv;
      when '[' then
        declare
          e_list pljson_list;
        begin
          indx := indx + 1;
          gs_parseArr(tokens, indx, e_list);
          mem := pljson_list.gs_to_json_value(e_list);
        end;
      when '{' then
        declare
          temp_pj pljson;
        begin
          indx := indx + 1;
          gs_parseObj(tokens, indx, temp_pj);
          mem := pljson.gs_to_json_value(temp_pj);
        end;
      else
        p_error('Found '||tok.type_name, tok);
    end case;
    mem.mapname := mem_name;
    mem.mapindx := mem_indx;
    indx := indx + 1;
  end;

  procedure gs_parseObj(tokens rToken[], indx inout integer, obj out pljson) as
    type memmap is table of number index by varchar2(4000); 
    mymap memmap;
    nullelemfound boolean := false;

    
    tok rToken;
    mem_name varchar(4000);
    arr pljson_value[] := array[]::pljson_value[];
  begin

    while (indx <= tokens.count) loop
      tok := tokens[indx];
      case tok.type_name
      when 'STRING' then
        --member
        mem_name := substr(tok.data, 1, 4000);
        -- begin exception
        if (mem_name is null) then
          if (nullelemfound) then
            p_error('Duplicate empty member: ', tok);
          else
            nullelemfound := true;
          end if;
        elsif (mymap(mem_name) is not null) then
          p_error('Duplicate member name: '||mem_name, tok);
        end if;
  
        indx := indx + 1;
        if (indx > tokens.count) then p_error('Unexpected end of input', tok); end if;
        tok := tokens[indx];
        indx := indx + 1;
        if (indx > tokens.count) then p_error('Unexpected end of input', tok); end if;
        if (tok.type_name = ':') then
          --parse
          declare
            jmb pljson_value;
            x number;
          begin
            x := arr.count + 1;
            gs_parseMem(tokens, indx, mem_name, x, jmb);
            arr.extend;
            arr[x] := jmb;
          end;

        else
          p_error('Expected '':''', tok);
        end if;
        --move indx forward if ',' is found
        if (indx > tokens.count) then p_error('Unexpected end of input', tok); end if;

        tok := tokens[indx];
        if (tok.type_name = ',') then
          
          indx := indx + 1;
          tok := tokens[indx];
          if (tok.type_name = '}') then --premature exit
            p_error('Premature exit in json object', tok);
          end if;
        elsif (tok.type_name != '}') then
           p_error('A comma seperator is probably missing', tok);
        end if;
      when '}' then
        obj := pljson.gs_pljson();
        obj.pljson_list_data := arr;
        return;
      else
        p_error('Expected string or }', tok);
      end case;
    end loop;

    p_error('} not found', tokens[indx-1]);
  end;

  function gs_parser(str varchar2) return pljson as
    tokens rToken[];
    obj pljson;
    indx integer := 1;
    jsrc json_src;
  begin
    -- update_decimalpoint();
    jsrc := gs_prepareVarchar2(str);
    gs_lexer(jsrc, tokens);
    if (tokens[indx].type_name = '{') then
      indx := indx + 1;
      gs_parseObj(tokens, indx, obj);
    else
      raise exception 'JSON Parser exception - no { start found';
    end if;
    if (tokens.count != indx) then
      p_error('} should end the JSON object', tokens[indx]);
    end if;

    return obj;
  end;

  function gs_parse_list(str varchar2) return pljson_list as
    tokens rToken[];
    obj pljson_list;
    indx integer := 1;
    jsrc json_src;
  begin
    -- update_decimalpoint();
    jsrc := gs_prepareVarchar2(str);
    gs_lexer(jsrc, tokens);
    if (tokens[indx].type_name = '[') then
      indx := indx + 1;
      gs_parseArr(tokens, indx, obj);
    else
      raise exception 'JSON List Parser exception - no [ start found';
    end if;
    if (tokens.count != indx) then
      p_error('] should end the JSON List object', tokens[indx]);
    end if;

    return obj;
  end;

  function gs_parse_any(str varchar2) return pljson_value as
    tokens rToken[];
    obj pljson_list;
    ret pljson_value;
    indx integer := 1;
    jsrc json_src;
  begin
    -- update_decimalpoint();
    jsrc := gs_prepareVarchar2(str);
    gs_lexer(jsrc, tokens);
    tokens[tokens.count+1].type_name := ']';
    gs_parseArr(tokens, indx, obj);
    if (tokens.count != indx) then
      p_error('] should end the JSON List object', tokens[indx]);
    end if;
    ret = pljson_list.gs_head(obj);
    return ret;
  end;

  function gs_parser(str clob) return pljson as
    tokens rToken[];
    obj pljson;
    indx integer := 1;
    jsrc json_src;
  begin
    -- update_decimalpoint();
    --mog_dbe_output.print_line('Using clob');
    jsrc := gs_prepareClob(str);
    gs_lexer(jsrc, tokens);

    -- for i in 1 .. tokens.count loop
    --   print_token(tokens[i]);
    -- end loop;

    if (tokens[indx].type_name = '{') then
      indx := indx + 1;
      gs_parseObj(tokens, indx, obj);
    else
      raise exception 'JSON Parser exception - no { start found';
    end if;
    if (tokens.count != indx) then
      p_error('} should end the JSON object', tokens[indx]);
    end if;

    return obj;
  end;

  function gs_parse_list(str clob) return pljson_list as
    tokens rToken[];
    obj pljson_list;
    indx integer := 1;
    jsrc json_src;
  begin
    -- update_decimalpoint();
    jsrc := gs_prepareClob(str);
    gs_lexer(jsrc, tokens);
    if (tokens[indx].type_name = '[') then
      indx := indx + 1;
      gs_parseArr(tokens, indx, obj);
    else
      raise exception 'JSON List Parser exception - no [ start found';
    end if;
    if (tokens.count != indx) then
      p_error('] should end the JSON List object', tokens[indx]);
    end if;

    return obj;
  end;

  
  function gs_parse_any(str clob) return pljson_value as
    tokens rToken[];
    obj pljson_list;
    ret pljson_value;
    indx integer := 1;
    jsrc json_src;
  begin
    -- update_decimalpoint();
    jsrc := gs_prepareClob(str);
    gs_lexer(jsrc, tokens);
    tokens[tokens.count+1].type_name := ']';
    gs_parseArr(tokens, indx, obj);
    if (tokens.count != indx) then
      p_error('] should end the JSON List object', tokens[indx]);
    end if;
    ret = pljson_list.gs_head(obj);
    return ret;
  end;

  procedure gs_remove_duplicates(obj inout pljson) as
    type memberlist is table of pljson_value index by varchar2(4000);
    members memberlist;
    nulljsonvalue pljson_value;
    validated pljson;
    indx varchar2(4000);
    tmp pljson_value;
  begin
    
    validated := pljson.gs_pljson();
    for i in 1 .. pljson.gs_count(obj) loop
      tmp = pljson.gs_get(obj, i);
      if (tmp.mapname is null) then
        nulljsonvalue := pljson.gs_get(obj, i);
      else
        tmp = pljson.gs_get(obj, i);
        members(tmp.mapname) := pljson.gs_get(obj, i);
      end if;
    end loop;

    pljson.gs_check_duplicate(validated, false);
    indx := members.first;
    loop
      exit when indx is null;
      pljson.gs_put(validated, indx, members(indx));
      indx := members.next(indx);
    end loop;
    
    if (nulljsonvalue is not null) then
      pljson.gs_put(validated, '', nulljsonvalue);
    end if;
    validated.check_for_duplicate := obj.check_for_duplicate;
    obj := validated;
  end;

  function gs_get_version() return varchar2 as
  begin
    return 'version1.0';
  end;

end pljson_parser;
/

create or replace package pljson_printer as
  
  indent_string varchar2(10) := '  '; --chr(9); for tab
  --newline_char varchar2(2) := chr(10); -- Mac style
  newline_char varchar2(2) := chr(13); -- Linux style
  ascii_output boolean not null := true;
  empty_string_as_null boolean not null := false;
  escape_solidus boolean not null := false;
  
  function gs_pretty_print(obj pljson, spaces boolean default true, line_length number default 0) return varchar2;
  function gs_pretty_print_list(obj pljson_list, spaces boolean default true, line_length number default 0) return varchar2;
  function gs_pretty_print_any(json_part pljson_value, spaces boolean default true, line_length number default 0) return varchar2;
  procedure gs_pretty_print(obj pljson, spaces boolean default true, buf inout clob, line_length number default 0, erase_clob boolean default true);
  procedure gs_pretty_print_list(obj pljson_list, spaces boolean default true, buf inout clob, line_length number default 0, erase_clob boolean default true);
  procedure gs_pretty_print_any(json_part pljson_value, spaces boolean default true, buf inout clob, line_length number default 0, erase_clob boolean default true);
  
  procedure gs_dbms_output_clob(my_clob clob, delim varchar2, jsonp varchar2 default null);
  procedure htp_output_clob(my_clob clob, jsonp varchar2 default null);
  -- made public just for testing/profiling...
  function gs_escapeString(str varchar2) return varchar2;

end pljson_printer;
/

create or replace package body pljson_printer as
  
  max_line_len number := 0;
  cur_line_len number := 0;

  type Tmap_char_string is table of varchar2(40) index by varchar2(1); /* index by unicode char */
  char_map Tmap_char_string;
  char_map_escape_solidus boolean := escape_solidus;
  char_map_ascii_output boolean := ascii_output;

  function gs_llcheck(str varchar2) return varchar2 as
  begin
    --mog_dbe_output.print_line(cur_line_len || ' : ' || str);
    if (max_line_len > 0 and length(str)+cur_line_len > max_line_len) then
      cur_line_len := length(str);
      return newline_char || str;
    else
      cur_line_len := cur_line_len + length(str);
      return str;
    end if;
  end;

  -- escapes a single character.
  function gs_escapeChar(ch char) return varchar2 deterministic is
     result varchar2(20);
  begin
      --backspace b = U+0008
      --formfeed  f = U+000C
      --newline   n = U+000A
      --carret    r = U+000D
      --tabulator t = U+0009
      result := ch;

      case ch
      when chr( 8) then result := '\b';
      when chr( 9) then result := '\t';
      when chr(10) then result := '\n';
      when chr(12) then result := '\f';
      when chr(13) then result := '\r';
      when chr(34) then result := '\"';
      when chr(47) then if (escape_solidus) then result := '\/'; end if;
      when chr(92) then result := '\\';
      else if (ascii(ch) >= 0 and ascii(ch) < 32) then
             result :=  '\u' || replace(substr(to_char(ascii(ch), 'XXXX'), 2, 4), ' ', '0');
        elsif (ascii_output) then
             result := replace(asciistr(ch), '\', '\u');
        end if;
      end case;
      return result;
  end;

  function gs_escapeString(str varchar2) return varchar2 as
    sb varchar2(32767) := '';
    buf varchar2(40);
    ch varchar2(1); /* unicode char */
  begin

    if (str is null) then return ''; end if;

    -- clear the cache if global parameters have been changed
    if char_map_escape_solidus <> escape_solidus or
       char_map_ascii_output <> ascii_output
    then
       char_map.delete;
       char_map_escape_solidus := escape_solidus;
       char_map_ascii_output := ascii_output;
    end if;

    for i in 1 .. length(str) loop
      ch := substr(str, i, 1) ;
      
      --begin
         -- it this char has already been processed, I have cached its escaped value
      --  buf := char_map(ch);

      --exception when no_Data_found then
         -- otherwise, i convert the value and add it to the cache
      --   buf := gs_escapeChar(ch);
      --   char_map(ch) := buf;
      --end;

      buf := ch;
      sb := sb || buf;
    end loop;
    return sb;
  end;

  function gs_newline(spaces boolean) return varchar2 as
  begin
    cur_line_len := 0;
    if (spaces) then return newline_char; else return ''; end if;
  end;

  function gs_tab(indent number, spaces boolean) return varchar2 as
    i varchar(200) := '';
  begin
    if (not spaces) then return ''; end if;
    for x in 1 .. indent loop i := i || indent_string; end loop;
    return i;
  end;

  function gs_getCommaSep(spaces boolean) return varchar2 as
  begin
    if (spaces) then return ', '; else return ','; end if;
  end;

  function gs_getMemName(mem pljson_value, spaces boolean) return varchar2 as
  begin
    if (spaces) then
      return gs_llcheck('"'||gs_escapeString(mem.mapname)||'"') || gs_llcheck(' : ');
    else
      return gs_llcheck('"'||gs_escapeString(mem.mapname)||'"') || gs_llcheck(':');
    end if;
  end;

  /* Clob method start here */
  procedure gs_add_to_clob(buf_lob inout clob, buf_str inout varchar2, str varchar2) as
  begin
    if (lengthb(str) > 32767 - lengthb(buf_str)) then
      mog_dbe_lob.append(buf_lob, buf_str);
      buf_str := str;
    else
      buf_str := buf_str || str;
    end if;
  end;

  procedure gs_flush_clob(buf_lob inout clob, buf_str inout varchar2) as
  begin
    mog_dbe_lob.append(buf_lob, buf_str);
  end;
  /* Clob method end here */

  /* Varchar2 method start here */
  procedure gs_add_buf(buf inout varchar2, str varchar2) as
  begin
    if (lengthb(str)>32767-lengthb(buf)) then
      raise exception 'Length of result JSON more than 32767 bytes. Use to_clob() procedures';
    end if;
    buf := buf || str;
  end;

  procedure gs_ppString(elem pljson_value, buf inout varchar2) is
    _offset number := 1;
    v_str varchar(5000);
    amount number := 5000;
  begin
    if empty_string_as_null and elem.extended_str is null and elem.str is null then
      gs_add_buf(buf, 'null');
    else
      -- gs_add_buf(buf, case when elem.num = 1 then '"' else '/**/' end);
      if (elem.num = 1) then
        gs_add_buf(buf, '"');
      else
        gs_add_buf(buf, "/**/");
      end if;

      if (elem.extended_str is not null) then
        while (_offset <= mog_dbe_lob.get_length(elem.extended_str)) loop
          v_str := mog_pkg_UTIL.lob_read(elem.extended_str, amount, _offset, 0);
          if (elem.num = 1) then
            gs_add_buf(buf, gs_escapeString(v_str));
          else
            gs_add_buf(buf, v_str);
          end if;
          _offset := _offset + amount;
        end loop;
      else
        if (elem.num = 1) then
          while (_offset <= length(elem.str)) loop
            v_str:=substr(elem.str, _offset, amount);
            gs_add_buf(buf, gs_escapeString(v_str));
            _offset := _offset + amount;
          end loop;
        else
          gs_add_buf(buf, elem.str);
        end if;
      end if;

      -- gs_add_buf(buf, case when elem.num = 1 then '"' else '/**/' end);
      if (elem.num = 1) then
        gs_add_buf(buf, '"');
      else
        gs_add_buf(buf, "/**/");
      end if;
    end if;
  end;

  procedure gs_ppObj(obj pljson, indent number, buf inout varchar2, spaces boolean);

  procedure gs_ppEA(input pljson_list, indent number, buf inout varchar2, spaces boolean) as
    elem pljson_value;
    arr pljson_value[];
    str varchar2(400);
  begin
    arr := input.pljson_list_data;  
    for y in 1 .. arr.count loop
      elem := arr[y];

      -- if (elem is not null) then
        case elem.typeval
          /* number */
          when 4 then
            str := pljson_value.gs_number_toString(elem);
            gs_add_buf(buf, gs_llcheck(str));
          /* string */
          when 3 then
            gs_ppString(elem, buf);
          /* bool */
          when 5 then
            if (pljson_value.gs_get_bool(elem)) then
              gs_add_buf(buf, gs_llcheck('true'));
            else
              gs_add_buf(buf, gs_llcheck('false'));
            end if;
          /* null */
          when 6 then
            gs_add_buf(buf, gs_llcheck('null'));
          /* array */
          when 2 then
            gs_add_buf( buf, gs_llcheck('['));
            gs_ppEA(pljson_list.gs_pljson_list(elem), indent, buf, spaces);
            gs_add_buf( buf, gs_llcheck(']'));
          /* object */
          when 1 then
            gs_ppObj(pljson.gs_pljson(elem), indent, buf, spaces);
          else
            gs_add_buf(buf, gs_llcheck(pljson_value.gs_get_type(elem)));
        end case;
      -- end if;
      if (y != arr.count) then gs_add_buf(buf, gs_llcheck(gs_getCommaSep(spaces))); end if;
    end loop;
  end;

  -- Mem = Member
  procedure gs_ppMem(mem pljson_value, indent number, buf inout varchar2, spaces boolean) as
    str varchar2(400) := '';
  begin
    gs_add_buf(buf, gs_llcheck(gs_tab(indent, spaces)) || gs_getMemName(mem, spaces));
    case mem.typeval
      /* number */
      when 4 then
        str := pljson_value.gs_number_toString(mem);
        gs_add_buf(buf, gs_llcheck(str));
      /* string */
      when 3 then
        gs_ppString(mem, buf);
      /* bool */
      when 5 then
        if (pljson_value.gs_get_bool(mem)) then
          gs_add_buf(buf, gs_llcheck('true'));
        else
          gs_add_buf(buf, gs_llcheck('false'));
        end if;
      /* null */
      when 6 then
        gs_add_buf(buf, gs_llcheck('null'));
      /* array */
      when 2 then
        gs_add_buf(buf, gs_llcheck('['));
        gs_ppEA(pljson_list.gs_pljson_list(mem), indent, buf, spaces);
        gs_add_buf(buf, gs_llcheck(']'));
      /* object */
      when 1 then
        gs_ppObj(pljson.gs_pljson(mem), indent, buf, spaces);
      else
        gs_add_buf(buf, gs_llcheck(pljson_value.gs_get_type(mem)));
    end case;
  end;

  procedure gs_ppObj(obj pljson, indent number, buf inout varchar2, spaces boolean) as
  begin
    gs_add_buf(buf, gs_llcheck('{') || gs_newline(spaces));
    for m in 1 .. obj.pljson_list_data.count loop
      gs_ppMem(obj.pljson_list_data[m], indent+1, buf, spaces);
      if (m != obj.pljson_list_data.count) then
        gs_add_buf(buf, gs_llcheck(',') || gs_newline(spaces));
      else
        gs_add_buf(buf, gs_newline(spaces));
      end if;
    end loop;
    gs_add_buf(buf, gs_llcheck(gs_tab(indent, spaces)) || gs_llcheck('}')); -- || chr(13);
  end;

  function gs_pretty_print(obj pljson, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767) := '';
  begin
    max_line_len := line_length;
    cur_line_len := 0;
    gs_ppObj(obj, 0, buf, spaces);
    return buf;
  end;

  function gs_pretty_print_list(obj pljson_list, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767) :='';
  begin
    max_line_len := line_length;
    cur_line_len := 0;
    gs_add_buf(buf, gs_llcheck('['));
    gs_ppEA(obj, 0, buf, spaces);
    gs_add_buf(buf, gs_llcheck(']'));
    return buf;
  end;

  function gs_pretty_print_any(json_part pljson_value, spaces boolean default true, line_length number default 0) return varchar2 as
    buf varchar2(32767) := '';
  begin
    case json_part.typeval
      /* number */
      when 4 then
        buf := pljson_value.gs_number_toString(json_part);
      /* string */
      when 3 then
        gs_ppString(json_part, buf);
      /* bool */
      when 5 then
        if (pljson_value.gs_get_bool(json_part)) then buf := 'true'; else buf := 'false'; end if;
      /* null */
      when 6 then
        buf := 'null';
      /* array */
      when 2 then
        buf := gs_pretty_print_list(pljson_list.gs_pljson_list(json_part), spaces, line_length);
      /* object */
      when 1 then
        buf := gs_pretty_print(pljson.gs_pljson(json_part), spaces, line_length);
      else
        buf := 'weird error: ' || pljson_value.gs_get_type(json_part);
    end case;
    return buf;
  end;

  procedure gs_pretty_print(obj pljson, spaces boolean default true, buf inout clob, line_length number default 0, erase_clob boolean default true) as
    buf_str varchar2(32767);
    amount number := mog_dbe_lob.get_length(buf);
  begin
    if (erase_clob and amount > 0) then
      mog_dbe_lob.STRIP(buf, 0);
    end if;
    
    buf_str := gs_pretty_print(obj, spaces, line_length);
    gs_flush_clob(buf, buf_str);
  end;

  procedure gs_pretty_print_list(obj pljson_list, spaces boolean default true, buf inout clob, line_length number default 0, erase_clob boolean default true) as
    buf_str varchar2(32767);
    amount number := mog_dbe_lob.get_length(buf);
  begin
    if (erase_clob and amount > 0) then
      mog_dbe_lob.STRIP(buf, 0);
    end if;

    buf_str := gs_pretty_print_list(obj, spaces, line_length);
    gs_flush_clob(buf, buf_str);
  end;

  procedure gs_pretty_print_any(json_part pljson_value, spaces boolean default true, buf inout clob, line_length number default 0, erase_clob boolean default true) as
    buf_str varchar2(32767) := '';
    amount number := mog_dbe_lob.get_length(buf);
  begin
    if (erase_clob and amount > 0) then
      mog_dbe_lob.STRIP(buf, 0);
    end if;

    buf_str := gs_pretty_print_any(json_part, spaces, line_length);
    gs_flush_clob(buf, buf_str);
  end;

  procedure gs_dbms_output_clob(my_clob clob, delim varchar2, jsonp varchar2 default null) as
    prev number := 1;
    indx number := 1;
    size_of_nl number := length(delim);
    v_str varchar2(32767);
    amount number;
    max_string_chars number := 5000; 
  begin

    if (jsonp is not null) then mog_dbe_output.print_line(jsonp||'('); end if;
    while (indx != 0) loop
      --read every line
      indx := mog_dbe_lob.match(my_clob, delim, prev+1);

      if (indx = 0) then
        --emit from prev to end;
        amount := max_string_chars;
        
        loop
          -- mog_dbe_lob.read(my_clob, amount, prev, v_str); mog_dbe_lob.read not exists
          v_str := mog_pkg_UTIL.lob_read(my_clob, amount, prev, 0);

          mog_dbe_output.print_line(v_str);
          prev := prev+amount;
          exit when prev >= mog_dbe_lob.get_length(my_clob);
        end loop;
      else
        amount := indx - prev;
        if (amount > max_string_chars) then
          amount := max_string_chars;
          
          loop
            -- mog_dbe_lob.read(my_clob, amount, prev, v_str); mog_dbe_lob.read not exists
            v_str := mog_pkg_UTIL.lob_read(my_clob, amount, prev, 0);
            
            mog_dbe_output.print_line(v_str);
            prev := prev+amount;
            amount := indx - prev;
            exit when prev >= indx - 1;
            if (amount > max_string_chars) then
              amount := max_string_chars;
            end if;
          end loop;
          prev := indx + size_of_nl;
        else
          -- mog_dbe_lob.read(my_clob, amount, prev, v_str); mog_dbe_lob.read not exists
          v_str := mog_pkg_UTIL.lob_read(my_clob, amount, prev, 0);
          mog_dbe_output.print_line(v_str);
          prev := indx + size_of_nl;
        end if;
      end if;

    end loop;
    if (jsonp is not null) then mog_dbe_output.print_line(')'); end if;
  end;

  procedure htp_output_clob(my_clob clob, jsonp varchar2 default null) as
    l_amt number default 4096;
    l_off number default 1;
    l_str varchar2(32000);
  begin
    raise NOTICE '%', 'NOT SUPPORT NOW';
    -- if (jsonp is not null) then htp.prn(jsonp||'('); end if;
    --begin
    --  loop
    --    mog_dbe_lob.read( my_clob, l_amt, l_off, l_str);
    --    htp.prn( l_str );
    --    l_off := l_off+l_amt;
    --  end loop;
    --exception
    --  when no_data_found then NULL;
    --end;
    -- if (jsonp is not null) then htp.prn(')'); end if;
  end;

end pljson_printer;
/

create or replace package body pljson_ext as
  
  /*
  procedure gs_next_char as
  begin
    if (indx <= length(json_path)) then
      buf := substr(json_path, indx, 1);
      indx := indx + 1;
    else
      buf := null;
    end if;
  end;
  --skip ws
  procedure skipws as begin while (buf in (chr(9), chr(10), chr(13), ' ')) loop gs_next_char; end loop; end;
  */

  --Json Path parser
  function gs_parsePath(json_path varchar2, base number default 1) return pljson_list as
    build_path varchar2(32767) := '[';
    buf varchar2(4);
    endstring varchar2(1);
    indx number := 1;
    ret pljson_list;
  begin
    -- gs_next_char
    if (indx <= length(json_path)) then
      buf := substr(json_path, indx, 1);
      indx := indx + 1;
    else
      buf := null;
    end if;

    while (buf is not null) loop
      if (buf = '.') then
        -- gs_next_char
        if (indx <= length(json_path)) then
          buf := substr(json_path, indx, 1);
          indx := indx + 1;
        else
          buf := null;
        end if;
        
        if (buf is null) then 
          raise exception 'JSON Path parse error: . is not a valid json_path end'; 
        end if;
        if (not regexp_like(buf, '^[[:alnum:]\_ ]+', 'c')) then
          raise exception 'JSON Path parse error: alpha-numeric character';
        end if;

        if (build_path != '[') then 
          build_path := build_path || ','; 
        end if;
        
        build_path := build_path || '"';
        while (regexp_like(buf, '^[[:alnum:]\_ ]+', 'c')) loop
          build_path := build_path || buf;
          -- gs_next_char
          if (indx <= length(json_path)) then
            buf := substr(json_path, indx, 1);
            indx := indx + 1;
          else
            buf := null;
          end if;
        end loop;
        build_path := build_path || '"';

      elsif (buf = '[') then
        -- gs_next_char
        if (indx <= length(json_path)) then
          buf := substr(json_path, indx, 1);
          indx := indx + 1;
        else
          buf := null;
        end if;
        --skip ws
        while (buf in (chr(9), chr(10), chr(13), ' ')) loop 
          if (indx <= length(json_path)) then
            buf := substr(json_path, indx, 1);
            indx := indx + 1;
          else
            buf := null;
          end if; 
        end loop;

        if (buf is null) then 
          raise exception 'JSON Path parse error: [ is not a valid json_path end'; 
        end if;
        if (buf in ('1','2','3','4','5','6','7','8','9') or (buf = '0' and base = 0)) then
          if (build_path != '[') then 
            build_path := build_path || ','; 
          end if;
          while (buf in ('0','1','2','3','4','5','6','7','8','9')) loop
            build_path := build_path || buf;
            -- gs_next_char
            if (indx <= length(json_path)) then
              buf := substr(json_path, indx, 1);
              indx := indx + 1;
            else
              buf := null;
            end if; 
          end loop;
        elsif (regexp_like(buf, '^(\"|\'')', 'c')) then
          endstring := buf;
          if (build_path != '[') then 
            build_path := build_path || ','; 
          end if;
          build_path := build_path || '"';
          -- gs_next_char
          if (indx <= length(json_path)) then
            buf := substr(json_path, indx, 1);
            indx := indx + 1;
          else
            buf := null;
          end if; 

          if (buf is null) then 
            raise exception 'JSON Path parse error: premature json_path end'; 
          end if;
          while (buf != endstring) loop
            build_path := build_path || buf;
            -- gs_next_char
            if (indx <= length(json_path)) then
              buf := substr(json_path, indx, 1);
              indx := indx + 1;
            else
              buf := null;
            end if; 
            if (buf is null) then 
              raise exception 'JSON Path parse error: premature json_path end'; 
            end if;
            if (buf = '\') then
              -- gs_next_char
              if (indx <= length(json_path)) then
                buf := substr(json_path, indx, 1);
                indx := indx + 1;
              else
                buf := null;
              end if; 
              build_path := build_path || '\' || buf;
              -- gs_next_char
              if (indx <= length(json_path)) then
                buf := substr(json_path, indx, 1);
                indx := indx + 1;
              else
                buf := null;
              end if; 
            end if;
          end loop;
          build_path := build_path || '"';
          -- gs_next_char
          if (indx <= length(json_path)) then
            buf := substr(json_path, indx, 1);
            indx := indx + 1;
          else
            buf := null;
          end if; 
        else
          raise exception 'JSON Path parse error';
        end if;
        --skip ws
        while (buf in (chr(9), chr(10), chr(13), ' ')) loop 
          if (indx <= length(json_path)) then
            buf := substr(json_path, indx, 1);
            indx := indx + 1;
          else
            buf := null;
          end if; 
        end loop;
        if (buf is null) then 
          raise exception 'JSON Path parse error: premature json_path end'; 
        end if;
        if (buf != ']') then 
          raise exception 'JSON Path parse error: no array ending found. found: '; 
        end if;
        -- gs_next_char
        if (indx <= length(json_path)) then
          buf := substr(json_path, indx, 1);
          indx := indx + 1;
        else
          buf := null;
        end if; 
        --skip ws
        while (buf in (chr(9), chr(10), chr(13), ' ')) loop 
          if (indx <= length(json_path)) then
            buf := substr(json_path, indx, 1);
            indx := indx + 1;
          else
            buf := null;
          end if; 
        end loop;
      elsif (build_path = '[') then
        if (not regexp_like(buf, '^[[:alnum:]\_ ]+', 'c')) then
          raise exception 'JSON Path parse error';
        end if;
        build_path := build_path || '"';
        while (regexp_like(buf, '^[[:alnum:]\_ ]+', 'c')) loop
          build_path := build_path || buf;
          -- gs_next_char
          if (indx <= length(json_path)) then
            buf := substr(json_path, indx, 1);
            indx := indx + 1;
          else
            buf := null;
          end if; 
        end loop;
        build_path := build_path || '"';
      else
        raise exception 'JSON Path parse error';
      end if;

    end loop;

    build_path := build_path || ']';
    build_path := replace(replace(replace(replace(replace(build_path, chr(9), '\t'), chr(10), '\n'), chr(13), '\f'), chr(8), '\b'), chr(14), '\r');

    ret := pljson_list.gs_pljson_list(build_path);
    if (base != 1) then
      --fix base 0 to base 1
      declare
        elem pljson_value;
      begin
        for i in 1 .. ret.count loop
          elem := pljson_list.gs_get(ret, i);
          if (pljson_value.gs_is_number(elem)) then
            pljson_list.gs_replace(ret, i, pljson_value.gs_get_number(elem)+1);
          end if;
        end loop;
      end;
    end if;
    return ret;
  end;

  --JSON Path getters
  function gs_get_json_value(obj pljson, v_path varchar2, base number default 1) return pljson_value as
    path pljson_list;
    ret pljson_value;
    o pljson; 
    l pljson_list;
  begin
  
    path := gs_parsePath(v_path, base);
    ret := pljson.gs_to_json_value(obj);
    if (pljson_list.gs_count(path) = 0) then 
      return ret; 
    end if;

    for i in 1 .. pljson_list.gs_count(path) loop
      if (pljson_value.gs_is_string(pljson_list.gs_get(path, i))) then
        --string fetch only on json
        o := pljson.gs_pljson(ret);
        ret := pljson.gs_get(o, pljson_value.gs_get_string(pljson_list.gs_get(path, i)));
      else
        --number fetch on json and json_list
        if (pljson_value.gs_is_array(ret)) then
          l := pljson_list.gs_pljson_list(ret);
          ret := pljson_list.gs_get(l, pljson_value.gs_get_number(pljson_list.gs_get(path, i)));
        else
          o := pljson.gs_pljson(ret);
          l := pljson.gs_get_values(o);
          ret := pljson_list.gs_get(l, pljson_value.gs_get_number(pljson_list.gs_get(path, i)));
        end if;
      end if;
    end loop;

    return ret;
  end;

  --JSON Path getters
  function gs_get_string(obj pljson, path varchar2, base number default 1) return varchar2 as
    temp pljson_value;
  begin
    temp := gs_get_json_value(obj, path, base);
    if (temp is null or not pljson_value.gs_is_string(temp)) then
      return null;
    else
      return pljson_value.gs_get_string(temp);
    end if;
  end;

  function gs_get_number(obj pljson, path varchar2, base number default 1) return number as
    temp pljson_value;
  begin
    temp := gs_get_json_value(obj, path, base);
    if (temp is null or not pljson_value.gs_is_number(temp)) then
      return null;
    else
      return pljson_value.gs_get_number(temp);
    end if;
  end;
  
  function gs_get_double(obj pljson, path varchar2, base number default 1) return binary_double as
    temp pljson_value;
  begin
    temp := gs_get_json_value(obj, path, base);
    if (temp is null or not pljson_value.gs_is_number(temp)) then
      return null;
    else
      return pljson_value.gs_get_double(temp);
    end if;
  end;

  function gs_get_json(obj pljson, path varchar2, base number default 1) return pljson as
    temp pljson_value;
    ret pljson;
  begin
    temp := gs_get_json_value(obj, path, base);
    if (temp is null or not pljson_value.gs_is_object(temp)) then
      return null;
    else
      ret = pljson.gs_pljson(temp);
      return ret;
    end if;
  end;

  function gs_get_json_list(obj pljson, path varchar2, base number default 1) return pljson_list as
    temp pljson_value;
    ret pljson_list;
  begin
    temp := gs_get_json_value(obj, path, base);
    if (temp is null or not pljson_value.gs_is_array(temp)) then
      return null;
    else
      ret = pljson_list.gs_pljson_list(temp);
      return ret;
    end if;
  end;

  function gs_get_bool(obj pljson, path varchar2, base number default 1) return boolean as
    temp pljson_value;
  begin
    temp := gs_get_json_value(obj, path, base);
    if (temp is null or not pljson_value.gs_is_bool(temp)) then
      return null;
    else
      return pljson_value.gs_get_bool(temp);
    end if;
  end;

  function gs_get_date(obj pljson, path varchar2, base number default 1) return date as
    temp pljson_value;
  begin
    temp := gs_get_json_value(obj, path, base);
    if (temp is null or not gs_is_date(temp)) then
      return null;
    else
      return pljson_ext.gs_to_date(temp);
    end if;
  end;

  --extra function checks if number has no fraction
  function gs_is_integer(v pljson_value) return boolean as
    num number;
    num_double binary_double;
    int_number number(38); 
    int_double binary_double;
  begin
    
    if (not pljson_value.gs_is_number(v)) then
      raise exception 'not a number-value';
    end if;
  
    if (pljson_value.gs_is_number_repr_number(v)) then
      num := pljson_value.gs_get_number(v);
      int_number := trunc(num);
      return (int_number = num); 
    elsif (pljson_value.gs_is_number_repr_double(v)) then
      num_double := pljson_value.gs_get_double(v);
      int_double := trunc(num_double);
      return (int_double = num_double); 
    else
      return false;
    end if;
    return false;
  end;

  --extension enables json to store dates without compromising the implementation
  function gs_to_json_value(d date) return pljson_value as
    ret pljson_value;
  begin
    ret = pljson_value.gs_pljson_value(to_char(d, format_string));
    return ret;
  end;

  --notice that a date type in json is also a varchar2
  function gs_is_date(v pljson_value) return boolean as
    temp date;
  begin
    temp := pljson_ext.gs_to_date(v);
    return true;
    -- exception
    -- when others then
    -- return false;
  end;

  --conversion is needed to extract dates
  function gs_to_date(v pljson_value) return date as
  begin
    if (pljson_value.gs_is_string(v)) then
      -- return STANDARD.to_date(pljson_value.gs_get_string(v), format_string);
      return to_date(pljson_value.gs_get_string(v), format_string);
    else
      raise exception 'Anydata did not contain a date-value';
    end if;
  end;

  -- alias so that old code doesn't break
  function gs_to_date2(v pljson_value) return date as
  begin
    return gs_to_date(v);
  end;

  function gs_decodeBase64Clob2Blob(p_clob clob) return blob as
    r_blob blob;
    clob_size number;
    pos number;
    c_buf varchar2(32767);
    r_buf raw(32767);
    v_read_size number;
    v_line_size number;
  begin
    
    mog_dbe_lob.create_temporary(r_blob, false, 0);
    clob_size := mog_dbe_lob.get_length(p_clob);
    v_line_size := 64;
    if clob_size >= 65 and mog_dbe_lob.substr(p_clob, 1, 65) = chr(10) then
      v_line_size := 65;
    elsif clob_size >= 66 and mog_dbe_lob.substr(p_clob, 1, 65) = chr(13) then
      v_line_size := 66;
    elsif clob_size >= 77 and mog_dbe_lob.substr(p_clob, 1, 77) = chr(10) then
      v_line_size := 77;
    elsif clob_size >= 78 and mog_dbe_lob.substr(p_clob, 1, 77) = chr(13) then
      v_line_size := 78;
    end if;
    v_read_size := floor(32767/v_line_size)*v_line_size;
    
    pos := 1;
    while (pos < clob_size) loop
      c_buf := mog_pkg_UTIL.lob_read(p_clob, v_read_size, pos, 0);
      r_buf := decode(mog_pkg_UTIL.raw_cast_from_varchar2(c_buf), 'base64');
      -- r_buf := mog_pkg_UTIL.raw_cast_from_varchar2(c_buf);
      mog_dbe_lob.write_append(r_blob, mog_dbe_raw.get_length(r_buf), r_buf);
      pos := pos + v_read_size;
    end loop;
    
    return r_blob;
  end;

  function gs_encodeBase64Blob2Clob(p_blob blob) return clob as
    r_clob clob;
    c_step integer := 12000;
    c_buf varchar2(32767);
  begin
    
    if p_blob is not null then
      mog_dbe_lob.create_temporary(r_clob, false, 0);
      for i in 0 .. trunc((mog_dbe_lob.get_length(p_blob) - 1)/c_step) loop
        
        c_buf := encode(mog_pkg_UTIL.raw_cast_to_varchar2(mog_dbe_lob.substr(p_blob, c_step, i * c_step + 1))::bytea, 'base64');
        -- c_buf := mog_pkg_UTIL.raw_cast_to_varchar2(mog_dbe_lob.substr(p_blob, c_step, i * c_step + 1));
        if substr(c_buf, length(c_buf)) != chr(10) then
          c_buf := c_buf || CHR(13) || CHR(10);
        end if;
        mog_dbe_lob.write_append(r_clob, length(c_buf), c_buf);
      end loop;
    end if;
    
    return r_clob;
  end;

  /* JSON Path putter internal function */
  procedure gs_put_internal(obj inout pljson, v_path varchar2, elem pljson_value, base number) as
    val pljson_value;
    path pljson_list;
    backreference pljson_list;

    keyval pljson_value; 
    keynum number; 
    keystring varchar2(4000);
    temp pljson_value;
    obj_temp  pljson;
    list_temp pljson_list;
    inserter pljson_value;
  begin
    val := elem;
    path := gs_parsePath(v_path, base);
    if (pljson_list.gs_count(path) = 0) then 
      raise exception 'PLJSON_EXT put error: cannot put with empty string.'; 
    end if;

    --build backreference
    for i in 1 .. pljson_list.gs_count(path) loop
      --backreference.print(false);
      keyval := pljson_list.gs_get(path, i);
      if (pljson_value.gs_is_number(keyval)) then
        --number index
        keynum := pljson_value.gs_get_number(keyval);
        if ((not pljson_value.gs_is_object(temp)) and (not pljson_value.gs_is_array(temp))) then
          if (val is null) then 
            return; 
          end if;
          pljson_list.gs_remove_last(backreference);
          temp := pljson_list.gs_to_json_value(pljson_list.gs_pljson_list());
          pljson_list.gs_append(backreference, temp);
        end if;

        if (pljson_value.gs_is_object(temp)) then
          obj_temp := pljson.gs_pljson(temp);
          if (pljson.gs_count(obj_temp) < keynum) then
            if (val is null) then 
              return; 
            end if;
            raise exception 'PLJSON_EXT put error: access object with too few members.';
          end if;
          temp := pljson.gs_get(obj_temp, keynum);
        else
          list_temp := pljson_list.gs_pljson_list(temp);
          if (pljson_list.gs_count(list_temp) < keynum) then
            if (val is null) then 
              return; 
            end if;
            --raise error or quit if val is null
            for i in pljson_list.gs_count(list_temp)+1 .. keynum loop
              pljson_list.gs_append(list_temp, pljson_value.gs_pljson_value());
            end loop;
            pljson_list.gs_remove_last(backreference);
            pljson_list.gs_append(backreference, list_temp);
          end if;

          temp := pljson_list.gs_get(list_temp, keynum);
        end if;
      else
        --string index
        keystring := pljson_value.gs_get_string(keyval);
        if (not pljson_value.gs_is_object(temp)) then
          --backreference.print;
          if (val is null) 
            then return; 
          end if;
          pljson_list.gs_remove_last(backreference);
          temp := pljson.gs_to_json_value(pljson.gs_pljson());
          pljson_list.gs_append(backreference, temp);
          --raise_application_error(-20110, 'PLJSON_EXT put error: trying to access a non object with a string.');
        end if;
        obj_temp := pljson.gs_pljson(temp);
        temp := pljson.gs_get(obj_temp, keystring);
      end if;

      if (temp is null) then
        if (val is null) then 
          return; 
        end if;

        keyval := pljson_list.gs_get(path, i+1);
        if (keyval is not null and pljson_value.gs_is_number(keyval)) then
          temp := pljson_list.gs_to_json_value(pljson_list.gs_pljson_list());
        else
          temp := pljson.gs_to_json_value(pljson.gs_pljson());
        end if;
      end if;
      pljson_list.gs_append(backreference, temp);
    end loop;

    --  backreference.print(false);
    --  path.print(false);

    --use backreference and path together
    inserter := val;
    for i in reverse 1 .. pljson_list.gs_count(backreference) loop
      -- inserter.print(false);
      if (i = 1) then
        keyval := pljson_list.gs_get(path, 1);
        if (pljson_value.gs_is_string(keyval)) then
          keystring := pljson_value.gs_get_string(keyval);
        else
          keynum := pljson_value.gs_get_number(keyval);
          declare
            t1 pljson_value;
          begin
            t1 := pljson.gs_get(obj, keynum);
            keystring := t1.mapname;
          end;
        end if;
        if (inserter is null) then 
          pljson.gs_remove(obj, keystring); 
        else 
          pljson.gs_put(obj, keystring, inserter); 
        end if;
      else
        temp := pljson_list.gs_get(backreference, i-1);
        if (pljson_value.gs_is_object(temp)) then
          keyval := pljson_list.gs_get(path, i);
          obj_temp := pljson.gs_pljson(temp);
          if (pljson_value.gs_is_string(keyval)) then
            keystring := pljson_value.gs_get_string(keyval);
          else
            keynum := pljson_value.gs_get_number(keyval);
            declare
              t1 pljson_value;
            begin
              t1 := pljson.gs_get(obj_temp, keynum);
              keystring := t1.mapname;
            end;
          end if;
          if (inserter is null) then
            pljson.gs_remove(obj_temp, keystring);
            if (obj_temp.count > 0) then 
              inserter := pljson.gs_to_json_value(obj_temp); 
            end if;
          else
            pljson.gs_put(obj_temp, keystring, inserter);
            inserter := pljson.gs_to_json_value(obj_temp);
          end if;
        else
          --array only number
          keynum := pljson_value.gs_get_number(pljson_list.gs_get(path, i));
          list_temp := pljson_list.gs_pljson_list(temp);
          pljson_list.gs_remove(list_temp, keynum);
          if (not inserter is null) then
            pljson_list.gs_append(list_temp, inserter, keynum);
            inserter := pljson_list.gs_to_json_value(list_temp);
          else
            if (pljson_list.gs_count(list_temp) > 0) then 
              inserter := pljson_list.gs_to_json_value(list_temp); 
            end if;
          end if;
        end if;
      end if;

    end loop;
  end;

  procedure gs_put(obj inout pljson, path varchar2, elem varchar2, base number default 1) as
  begin
    if elem is null then
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(), base);
    else
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(elem), base);
    end if;
  end;

  procedure gs_put(obj inout pljson, path varchar2, elem number, base number default 1) as
  begin
    if elem is null then
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(), base);
    else
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(elem), base);
    end if;
  end;

  procedure gs_put(obj inout pljson, path varchar2, elem binary_double, base number default 1) as
  begin
    if elem is null then
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(), base);
    else
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(elem), base);
    end if;
  end;

  procedure gs_put(obj inout pljson, path varchar2, elem pljson, base number default 1) as
  begin
    if elem is null then
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(), base);
    else
      gs_put_internal(obj, path, pljson.gs_to_json_value(elem), base);
    end if;
  end;

  procedure gs_put(obj inout pljson, path varchar2, elem pljson_list, base number default 1) as
  begin
    if elem is null then
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(), base);
    else
      gs_put_internal(obj, path, pljson_list.gs_to_json_value(elem), base);
    end if;
  end;

  procedure gs_put(obj inout pljson, path varchar2, elem boolean, base number default 1) as
  begin
    if elem is null then
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(), base);
    else
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(elem), base);
    end if;
  end;

  procedure gs_put(obj inout pljson, path varchar2, elem pljson_value, base number default 1) as
  begin
    if elem is null then
      gs_put_internal(obj, path, pljson_value.gs_pljson_value(), base);
    else
      gs_put_internal(obj, path, elem, base);
    end if;
  end;

  procedure gs_put(obj inout pljson, path varchar2, elem date, base number default 1) as
  begin
    if elem is null then
      gs_put_internal(obj, path, gs_pljson_value(), base);
    else
      gs_put_internal(obj, path, pljson_ext.gs_to_json_value(elem), base);
    end if;
  end;

  procedure gs_remove(obj inout pljson, path varchar2, base number default 1) as
  begin
    pljson_ext.gs_put_internal(obj, path, null, base);
  --    if (json_ext.gs_get_json_value(obj, path) is not null) then
  --    end if;
  end;

  --Pretty print with JSON Path
  procedure gs_pp(obj pljson, v_path varchar2) as --using dbms_output.put_line
    json_part pljson_value;
  begin
    json_part := gs_get_json_value(obj, v_path);
    if (json_part is null) then
      mog_dbe_output.print_line('');
    else
      mog_dbe_output.print_line(pljson_printer.gs_pretty_print_any(json_part)); --escapes a possible internal string
    end if; 
  end;

  procedure pp_htp(obj pljson, v_path varchar2) as --using htp.print
    json_part pljson_value;
  begin
  /*
    json_part := pljson_ext.gs_get_json_value(obj, v_path);
    if (json_part is null) then
      htp.print;
    else
      htp.print(pljson_printer.gs_pretty_print_any(json_part, false));
    end if;
  */
  end;

  function gs_base64(binarydata blob) return pljson_list as
    obj pljson_list;
    c clob;

    v_clob_offset number := 1;
    v_amount integer;
  begin
     
    mog_dbe_lob.create_temporary(c, false, 0);
    c := gs_encodeBase64Blob2Clob(binarydata);
    v_amount := mog_dbe_lob.get_length(c);
    v_clob_offset := 1;
    --dbms_output.put_line('V amount: '||v_amount);
    while (v_clob_offset < v_amount) loop
      --dbms_output.put_line(v_offset);
      --temp := ;
      --dbms_output.put_line('size: '||length(temp));
      pljson_list.gs_append(obj, mog_dbe_lob.SUBSTR(c, 4000, v_clob_offset));
      v_clob_offset := v_clob_offset + 4000;
    end loop;
    -- dbms_lob.freetemporary(c);
  --dbms_output.put_line(obj.count);
  --dbms_output.put_line(obj.get_last().to_char);
    return obj;
  end;

  function gs_base64(l pljson_list) return blob as
    c clob;
    b_ret blob;
  begin
    mog_dbe_lob.create_temporary(c, false, 0);
    for i in 1 .. pljson_list.gs_count(l) loop
      mog_dbe_lob.append(c, pljson_value.gs_get_string(pljson_list.gs_get(l, i)));
    end loop;
    b_ret := gs_decodeBase64Clob2Blob(c);
    return b_ret;
  end;

  function gs_encode(binarydata blob) return pljson_value as
    obj pljson_value;
    c clob;
  begin
    mog_dbe_lob.create_temporary(c, false, 0);
    c := gs_encodeBase64Blob2Clob(binarydata);
    -- c := mog_pkg_UTIL.lob_converttoclob(c, binarydata, 32767, 1, 1);
    obj := pljson_value.gs_pljson_value(c);
    return obj;
  end;

  function gs_decode(v pljson_value) return blob as
    c clob;
    b_ret blob;
  begin
    c := pljson_value.gs_get_clob(v);
    b_ret := gs_decodeBase64Clob2Blob(c);
    -- b_ret := mog_pkg_UTIL.lob_converttoblob(b_ret, c, 32767, 1, 1);
    return b_ret;
  end;

  procedure gs_blob2clob(b blob, c out clob, charset varchar2 default 'UTF8') as
    v_dest_offset integer := 1;
    v_src_offset integer := 1;
  begin
    mog_dbe_lob.create_temporary(c, false, 0);
    c := mog_pkg_UTIL.lob_converttoclob(c, b, 32767, 1, 1);
  end;

end pljson_ext;
/

create or replace package body pljson_value as

  function gs_pljson_value() return pljson_value as
    json_value pljson_value;
  begin 
    json_value.typeval := 6;
    return json_value;
  end;

  function gs_pljson_value(b boolean) return pljson_value as
    json_value pljson_value;
  begin 
    json_value.typeval := 5;
    json_value.num := 0;
    if(b) then 
      json_value.num := 1; 
    end if;
    if(b is null) then 
      json_value.typeval := 6; 
    end if;
    return json_value;
  end;

  function gs_pljson_value(str varchar2, esc boolean default true) return pljson_value as
    json_value pljson_value;
  begin
    json_value.typeval := 3;
    if(esc) then 
      json_value.num := 1; 
    else 
      json_value.num := 0; 
    end if; --message to pretty printer
    json_value.str := str;
    return json_value;
  end;

  function gs_pljson_value(str clob, esc boolean default true) return pljson_value as
    json_value pljson_value;
    max_string_chars number := 5000; 
    lengthcc number;
  begin
    json_value.typeval := 3;
    if(esc) then 
      json_value.num := 1; 
    else 
      json_value.num := 0; 
    end if; --message to pretty printer
   
    if (mog_dbe_lob.get_length(str) > max_string_chars) then
      json_value.extended_str := str;
    end if;
   
    if mog_dbe_lob.get_length(str) > 0 then
      json_value.str := mog_pkg_UTIL.lob_read(str, max_string_chars, 1, 0);
    end if;
    return json_value;
  end;

    function gs_pljson_value(num number) return pljson_value as
    json_value pljson_value;
  begin 
    json_value.typeval := 4;
    json_value.num := num;
    json_value.num_repr_number_p := 't';
    json_value.num_double := num;
    if (to_number(json_value.num_double) = json_value.num) then
      json_value.num_repr_double_p := 't';
    else
      json_value.num_repr_double_p := 'f';
    end if;
    
    if(json_value.num is null) then 
      json_value.typeval := 6; 
    end if;
    return json_value;
  end;
  
  function gs_pljson_value(num_double binary_double) return pljson_value as
    json_value pljson_value;
  begin 
    json_value.typeval := 4;
    json_value.num_double := num_double;
    json_value.num_repr_double_p := 't';
    json_value.num := num_double;
    -- if (to_binary_double(json_value.num) = json_value.num_double) then
    if (to_number(json_value.num) = json_value.num_double) then
      json_value.num_repr_number_p := 't';
    else
      json_value.num_repr_number_p := 'f';
    end if;
    if(json_value.num_double is null) then 
      json_value.typeval := 6; 
    end if;
    return json_value;
  end;

  function gs_pljson_value(elem pljson_element) return pljson_value as
    json_value pljson_value;
  begin 
    /*
    case
      when elem is of (pljson)      then self.typeval := 1;
      when elem is of (pljson_list) then self.typeval := 2;
      else raise_application_error(-20102, 'PLJSON_VALUE init error (PLJSON or PLJSON_LIST allowed)');
    end case;
    self.object_or_array := elem;
    if(self.object_or_array is null) then self.typeval := 6; end if;
    */
    raise exception 'pljson element not support now';
    return json_value;
  end;

  function gs_pljson_value(arr pljson_list) return pljson_value as
    json_value pljson_value;
  begin 
    json_value.typeval := 2;
    json_value.arr := arr;
    return json_value;
  end;

  function gs_pljson_value(obj pljson) return pljson_value as
    json_value pljson_value;
  begin 
    json_value.typeval := 1;
    json_value.obj := obj;
    return json_value;
  end;

  function gs_makenull() return pljson_value as
     json_value pljson_value;
  begin 
    return json_value;
  end;
  
  function gs_get_type(json_value pljson_value) return varchar2 as
    ret varchar2;
  begin 
    case json_value.typeval
    when 1 then ret := 'object';
    when 2 then ret := 'array';
    when 3 then ret := 'string';
    when 4 then ret := 'number';
    when 5 then ret := 'bool';
    when 6 then ret := 'null';
    else
      ret := 'unknown type';
    end case;
    return ret;
  end;
  
  function gs_get_string(json_value pljson_value, max_byte_size number default null, max_char_size number default null) return varchar2 as
  begin 
    if(json_value.typeval = 3) then
      if(max_byte_size is not null) then
        return substrb(json_value.str,1,max_byte_size);
      elsif (max_char_size is not null) then
        return substr(json_value.str,1,max_char_size);
      else
        return json_value.str;
      end if;
    end if;
    return null;
  end;
  
  procedure gs_get_string_clob(json_value pljson_value, buf inout clob) as
  begin 
    mog_dbe_lob.STRIP(buf, 0);
    if(json_value.typeval = 3) then
      if(json_value.extended_str is not null) then
        mog_dbe_lob.copy(buf, json_value.extended_str, mog_dbe_lob.get_length(json_value.extended_str));
      else
        mog_dbe_lob.write_append(buf, length(json_value.str), json_value.str);
      end if;
    end if;
  end;
  
  function gs_get_clob(json_value pljson_value) return clob as
  begin 
    if(json_value.typeval = 3) then
      if(json_value.extended_str is not null) then
        return json_value.extended_str;
      else
        return json_value.str;
      end if;
    end if;
    return null;
  end;  

  function gs_get_bool(json_value pljson_value) return boolean as
  begin 
    if(json_value.typeval = 5) then
      return json_value.num = 1;
    end if;
    return null;
  end;

  function gs_get_number(json_value pljson_value) return number as
  begin 
    if(json_value.typeval = 4) then
      return json_value.num;
    end if;
    return null;
  end;
  
  function gs_get_double(json_value pljson_value) return binary_double as
  begin 
    if(json_value.typeval = 4) then
      return json_value.num_double;
    end if;
    return null;
  end; 
  
  function gs_get_element(json_value pljson_value) return pljson_element as
  begin 
    if (json_value.typeval in (1,2)) then
      return json_value.object_or_array;
    end if;
    return null;
  end;
  
  function gs_get_null(json_value pljson_value) return varchar2 as
  begin 
    if(json_value.typeval = 6) then
      return 'null';
    end if;
    return null;
  end;
  
  function gs_is_string(json_value pljson_value) return boolean as
  begin 
    return json_value.typeval = 3;
  end;

  function gs_is_bool(json_value pljson_value) return boolean as
  begin 
    return json_value.typeval = 5;
  end;

  function gs_is_number(json_value pljson_value) return boolean as
  begin 
    return json_value.typeval = 4;
  end;

  function gs_is_number_repr_number(json_value pljson_value) return boolean as
  begin 
    if json_value.typeval != 4 then
      return false;
    end if;
    return (json_value.num_repr_number_p = 't');
  end;
  
  function gs_is_number_repr_double(json_value pljson_value) return boolean as
  begin 
    if json_value.typeval != 4 then
      return false;
    end if;
    return (json_value.num_repr_double_p = 't');
  end;

  function gs_is_object(json_value pljson_value) return boolean as
  begin 
    return json_value.typeval = 1;
  end;
  
  function gs_is_array(json_value pljson_value) return boolean as
  begin 
    return json_value.typeval = 2;
  end;

  function gs_is_null(json_value pljson_value) return boolean as
  begin 
    return json_value.typeval = 6;
  end;

  function gs_value_of(json_value pljson_value, max_byte_size number default null, max_char_size number default null) return varchar2 as
  begin 
    case json_value.typeval
    when 1 then return 'json object';
    when 2 then return 'json array';
    when 3 then return pljson_value.gs_get_string(json_value, max_byte_size, max_char_size);
    when 4 then return pljson_value.gs_get_number(json_value);
    when 5 then if(pljson_value.gs_get_bool(json_value)) then return 'true'; else return 'false'; end if;
    else return null;
    end case;
  end;
  
  procedure gs_parse_number(json_value inout pljson_value, str varchar2) as
  begin 
    if json_value.typeval != 4 then
      return;
    end if;
    
    json_value.num := to_number(str);
    json_value.num_repr_number_p := 't';
    -- json_value.num_double := to_binary_double(str);
    json_value.num_double := to_number(str);
    json_value.num_repr_double_p := 't';
    -- if (to_binary_double(json_value.num) != json_value.num_double) then
    if (to_number(json_value.num) != json_value.num_double) then
      json_value.num_repr_number_p := 'f';
    end if;
    if (to_number(json_value.num_double) != json_value.num) then
      json_value.num_repr_double_p := 'f';
    end if;
    exception
      when others then
        raise exception 'input str is not vailed';
  end;
  
  function gs_number_toString(json_value pljson_value) return varchar2 as
    num number;
    num_double binary_double;
    buf varchar2(4000);
  begin 
    if (json_value.num_repr_number_p = 't') then
      num := json_value.num;
      if (num > 1e127) then
        return '1e309'; -- json representation of infinity 
      end if;
      if (num < -1e127) then
        return '-1e309'; -- json representation of infinity 
      end if;
     
      buf := to_char(num);
      if (-1 < num and num < 0 and substr(buf, 1, 2) = '-.') then
        buf := '-0' || substr(buf, 2);
      elsif (0 < num and num < 1 and substr(buf, 1, 1) = '.') then
        buf := '0' || buf;
      end if;
      return buf;
    else
      num_double := json_value.num_double;
      if (num_double = +BINARY_DOUBLE_INFINITY) then
        return '1e309'; -- json representation of infinity
      end if;
      if (num_double = -BINARY_DOUBLE_INFINITY) then
        return '-1e309'; -- json representation of infinity
      end if;

      buf := to_char(num_double);
      if (-1 < num_double and num_double < 0 and substr(buf, 1, 2) = '-.') then
        buf := '-0' || substr(buf, 2);
      elsif (0 < num_double and num_double < 1 and substr(buf, 1, 1) = '.') then
        buf := '0' || buf;
      end if;
      return buf;
    end if;
  end;

  function gs_to_char(json_value pljson_value, spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin 
    return pljson_printer.gs_pretty_print_any(json_value, spaces, chars_per_line);
  end;
  
  -- procedure gs_to_clob(json_value pljson_value, buf inout clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  -- begin 
  --   if(spaces is null) then
  --     pljson_printer.gs_pretty_print_any(json_value, false, buf, chars_per_line, erase_clob);
  --   else
  --     pljson_printer.gs_pretty_print_any(json_value, spaces, buf, chars_per_line, erase_clob);
  --   end if;
  -- end;

  procedure gs_to_clob(json_value pljson_value, buf inout clob, spaces boolean default true, chars_per_line number default 0, erase_clob boolean default true) as
    my_bufstr varchar2;
  begin 
    my_bufstr := pljson_printer.gs_pretty_print_any(json_value, spaces, chars_per_line);
    if (erase_clob) then
      mog_dbe_lob.STRIP(buf,0);
    end if;
    mog_dbe_lob.append(buf, my_bufstr);
  end;
  
  -- procedure gs_print(json_value pljson_value, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as
  --   my_clob clob;
  -- begin 
  --   mog_dbe_lob.create_temporary(my_clob, true);
  --   if (chars_per_line>32512) then
  --     pljson_printer.gs_pretty_print_any(json_value, spaces, my_clob, 32512);
  --   else
  --      pljson_printer.gs_pretty_print_any(json_value, spaces, my_clob, chars_per_line);
  --   end if;
  --   pljson_printer.gs_dbms_output_clob(my_clob, pljson_printer.newline_char, jsonp);
  -- end;

  procedure gs_print(json_value pljson_value, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as
    my_clob clob;
    my_bufstr varchar2;
  begin 
    mog_dbe_lob.create_temporary(my_clob, true);
    if (chars_per_line>32512) then
      my_bufstr := pljson_printer.gs_pretty_print_any(json_value, spaces, 32512);
    else
      my_bufstr := pljson_printer.gs_pretty_print_any(json_value, spaces, chars_per_line);
    end if;
    mog_dbe_lob.append(my_clob, my_bufstr);
    pljson_printer.gs_dbms_output_clob(my_clob, pljson_printer.newline_char, jsonp);
  end;
  
  procedure htp(json_value pljson_value, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as
    my_clob clob;
  begin 
    raise exception 'htp not support';
    mog_dbe_lob.create_temporary(my_clob, true);
    pljson_printer.gs_pretty_print_any(json_value, spaces, my_clob, chars_per_line);
    pljson_printer.htp_output_clob(my_clob, jsonp);
  end;
  
end pljson_value;
/

create or replace package body pljson_list as

   function gs_pljson_list() return pljson_list as
     json_list pljson_list;
   begin
     return json_list;
   end;
   
   function gs_pljson_list(str varchar2) return pljson_list as
     json_list pljson_list;
   begin
      json_list := pljson_parser.gs_parse_list(str);
      return json_list;
   end;
   
   function gs_pljson_list(str clob) return pljson_list as
     json_list pljson_list;
   begin
      json_list := pljson_parser.gs_parse_list(str);
      return json_list;
   end;
   
   function gs_pljson_list(str blob, charset varchar2 default 'UTF8') return pljson_list as
     json_list pljson_list;
     c_str clob;
   begin
      pljson_ext.gs_blob2clob(str, c_str, charset);
      json_list := pljson_parser.gs_parse_list(c_str);
      -- dbms_lob.freetemporary(c_str);
      return json_list;
   end;
   
   function gs_pljson_list(str_array varchar2[]) return pljson_list as
     json_list pljson_list;
   begin
      -- json_list.pljson_list_data := pljson_value_array();
      for i in str_array.FIRST .. str_array.LAST loop
        gs_append(json_list, str_array[i]);
      end loop;
      return json_list;
   end;
   
   function gs_pljson_list(num_array number[]) return pljson_list as
     json_list pljson_list;
   begin
      for i in str_array.FIRST .. str_array.LAST loop
        gs_append(json_list, num_array[i]);
      end loop;
      return json_list;
   end;
   
   function gs_pljson_list(elem pljson_value) return pljson_list as
      ret_list pljson_list;
   begin
      -- self := treat(elem.object_or_array as pljson_list);
      ret_list := elem.arr;
      return ret_list;
   end;
   
   
  /* list management */
  procedure gs_append(json_list inout pljson_list, elem pljson_value, _position integer default null) as
    indx integer;
    insert_value pljson_value;
  begin 
    insert_value := elem;
    if insert_value is null then
      insert_value := pljson_value.gs_pljson_value();
    end if;
    if (_position is null or _position > pljson_list.gs_count(json_list)) then --end of list
      indx := pljson_list.gs_count(json_list) + 1;
      json_list.pljson_list_data.extend(1);
      json_list.pljson_list_data[indx] := insert_value;
    elsif (_position < 1) then --new first
      indx := pljson_list.gs_count(json_list);
      json_list.pljson_list_data.extend(1);
      for x in reverse 0 .. indx loop
        json_list.pljson_list_data[x+1] := json_list.pljson_list_data[x];
      end loop;
      json_list.pljson_list_data[0] := insert_value;
    else
      indx := pljson_list.gs_count(json_list);
      json_list.pljson_list_data.extend(1);
      for x in reverse _position .. indx loop
        json_list.pljson_list_data[x+1] := json_list.pljson_list_data(x);
      end loop;
      json_list.pljson_list_data[_position] := insert_value;
    end if;
  end;
  
  procedure gs_append(json_list inout pljson_list, elem varchar2, _position integer default null) as
  begin 
    gs_append(json_list, pljson_value.gs_pljson_value(elem), _position);
  end;
  
  procedure gs_append(json_list inout pljson_list, elem clob, _position integer default null) as
  begin 
    gs_append(json_list, pljson_value.gs_pljson_value(elem), _position);
  end;
  
  procedure gs_append(json_list inout pljson_list, elem number, _position integer default null) as
  begin 
    if (elem is null) then
    gs_append(json_list, pljson_value.gs_pljson_value(), _position);
  else
    gs_append(json_list, pljson_value.gs_pljson_value(elem), _position);
  end if;
  end;
  
  procedure gs_append(json_list inout pljson_list, elem binary_double, _position integer default null) as
  begin 
    if (elem is null) then
      gs_append(json_list, pljson_value.gs_pljson_value(), _position);
    else
      gs_append(json_list, pljson_value.gs_pljson_value(elem), _position);
    end if;
  end;
  
  procedure gs_append(json_list inout pljson_list, elem boolean, _position integer default null) as
  begin 
    if (elem is null) then
      gs_append(json_list, pljson_value.gs_pljson_value(), _position);
    else
      gs_append(json_list, pljson_value.gs_pljson_value(elem), _position);
    end if;
  end;
  
  procedure gs_append(json_list inout pljson_list, elem pljson_list, _position integer default null) as
  begin 
    if (elem is null) then
      gs_append(json_list, pljson_value.gs_pljson_value(), _position);
    else
      gs_append(json_list, pljson_list.gs_to_json_value(elem), _position);
    end if;
  end;

  procedure gs_remove(json_list inout pljson_list, _position integer) as
  begin 
    if (_position is null or _position < 1 or _position > pljson_list.gs_count(json_list)) then 
      return; 
    end if;
    for x in (_position+1) .. pljson_list.gs_count(json_list) loop
      json_list.pljson_list_data[x-1] := json_list.pljson_list_data[x];
    end loop;
    json_list.pljson_list_data.trim(1);
  end;
  
  procedure gs_remove_first(json_list inout pljson_list) as
  begin 
    for x in 2 .. pljson_list.gs_count(json_list) loop
      json_list.pljson_list_data[x-1] := json_list.pljson_list_data[x];
    end loop;
    if (pljson_list.gs_count(json_list) > 0) then
      json_list.pljson_list_data.trim(1);
    end if;
  end;
  
  procedure gs_remove_last(json_list inout pljson_list) as
  begin 
    if (pljson_list.gs_count(json_list) > 0) then
      json_list.pljson_list_data.trim(1);
  end if;
  end;
  
  function gs_count(json_list pljson_list) return number as
  begin 
    return json_list.pljson_list_data.count;
  end;
  
  function gs_get(json_list pljson_list, _position integer) return pljson_value as
    ret pljson_value;
  begin 
    if (pljson_list.gs_count(json_list) >= _position and _position > 0) then
      ret = json_list.pljson_list_data[_position];
      return ret;
    end if;
    return null; -- do not throw error, just return null
  end;
    
  function gs_get_string(json_list pljson_list, _position integer) return varchar2 as
    elem pljson_value;
    ret varchar2;
  begin 
    elem := pljson_list.gs_get(json_list, _position);
    ret = pljson_value.gs_get_string(elem);
    return ret;
  end;
  
  function gs_get_clob(json_list pljson_list, _position integer) return clob as
    elem pljson_value;
    ret clob;
  begin 
    elem := pljson_list.gs_get(json_list, _position);
    ret = pljson_value.gs_get_clob(elem);
    return ret;
  end;

  function gs_get_bool(json_list pljson_list, _position integer) return boolean as
    elem pljson_value;
    ret boolean;
  begin 
    elem := pljson_list.gs_get(json_list, _position);
    ret = pljson_value.gs_get_bool(elem);
    return ret;
  end;
  
  function gs_get_number(json_list pljson_list, _position integer) return number as
    elem pljson_value;
    ret number;
  begin 
    elem := pljson_list.gs_get(json_list, _position);
    ret = pljson_value.gs_get_number(elem);
    return ret;
  end;
  
  function gs_get_double(json_list pljson_list, _position integer) return binary_double as
    elem pljson_value;
    ret binary_double;
  begin 
    elem := pljson_list.gs_get(json_list, _position);
    ret = pljson_value.gs_get_double(elem);
    return ret;
  end;

  function gs_get_pljson_list(json_list pljson_list, _position integer) return pljson_list as
    elem pljson_value;
    ret pljson_list;
  begin
    elem := pljson_list.gs_get(json_list, _position);
    ret = pljson_list.gs_pljson_list(elem);
    -- return treat(elem.object_or_array as pljson_list);
    return ret;
  end;
  
  function gs_head(json_list pljson_list) return pljson_value as
    ret pljson_value;
  begin 
    if (pljson_list.gs_count(json_list) > 0) then
      ret = json_list.pljson_list_data[json_list.pljson_list_data.first];
      -- return json_list.pljson_list_data[0];
      return ret;
    end if;
    return null; -- do not throw error, just return null
  end;
    
  function gs_last(json_list pljson_list) return pljson_value as
    ret pljson_value;
  begin 
    if (pljson_list.gs_count(json_list) > 0) then
      ret = json_list.pljson_list_data[json_list.pljson_list_data.last];
      return ret;
    end if;
    return null; -- do not throw error, just return null
  end;
  
  function gs_tail(json_list pljson_list) return pljson_list as
    t pljson_list;
    ret pljson_list;
  begin 
    if (pljson_list.gs_count(json_list) > 0) then
      t := json_list; --pljson_list(self.to_json_value);
      pljson_list.gs_remove(t, 1);
      return t;
    else
      ret = pljson_list.gs_pljson_list();
      return ret;
    end if;
  end;

  procedure gs_replace(json_list inout pljson_list, _position integer, elem pljson_value) as
    insert_value pljson_value;
    indx number;
  begin 
    insert_value := elem;
    if insert_value is null then
      insert_value := pljson_value.gs_pljson_value();
    end if;
    if (_position > pljson_list.gs_count(json_list)) then --end of list
      indx := pljson_list.gs_count(json_list) + 1;
      json_list.pljson_list_data.extend(1);
      json_list.pljson_list_data[indx] := insert_value;
    elsif (_position < 1) then --maybe an error message here
      null;
    else
      json_list.pljson_list_data[_position] := insert_value;
    end if;
  end;
  
  procedure gs_replace(json_list inout pljson_list, _position integer, elem varchar2) as
  begin 
    gs_replace(json_list, _position, pljson_value.gs_pljson_value(elem));
  end;
  
  procedure gs_replace(json_list inout pljson_list, _position integer, elem clob) as
  begin 
    gs_replace(json_list, _position, pljson_value.gs_pljson_value(elem));
  end;
  
  procedure gs_replace(json_list inout pljson_list, _position integer, elem number) as
  begin 
    if (elem is null) then
      gs_replace(json_list, _position, pljson_value.gs_pljson_value());
    else
      gs_replace(json_list, _position, pljson_value.gs_pljson_value(elem));
    end if;
  end;
  
  procedure gs_replace(json_list inout pljson_list, _position integer, elem binary_double) as
  begin 
    if (elem is null) then
      gs_replace(json_list, _position, pljson_value.gs_pljson_value());
    else
      gs_replace(json_list, _position, pljson_value.gs_pljson_value(elem));
    end if;
  end;
  
  procedure gs_replace(json_list inout pljson_list, _position integer, elem boolean) as
  begin 
    if (elem is null) then
      gs_replace(json_list, _position, pljson_value.gs_pljson_value());
    else
      gs_replace(json_list, _position, pljson_value.gs_pljson_value(elem));
    end if;
  end;
  
  procedure gs_replace(json_list inout pljson_list, _position integer, elem pljson_list) as
  begin 
    if (elem is null) then
      gs_replace(json_list, _position, pljson_value.gs_pljson_value());
    else
      gs_replace(json_list, _position, pljson_list.gs_to_json_value(elem));
    end if;
  end;
  
  function gs_to_json_value(json_list pljson_list) return pljson_value as
    ret pljson_value;
  begin 
    ret = pljson_value.gs_pljson_value(json_list);
    return ret;
  end;
    
  /* output methods */
  function gs_to_char(json_list pljson_list, spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin 
    if (spaces is null) then
      return pljson_printer.gs_pretty_print_list(json_list, chars_per_line);
    else
      return pljson_printer.gs_pretty_print_list(json_list, spaces, chars_per_line);
    end if;
  end;
  
  procedure gs_to_clob(json_list pljson_list, buf inout clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  begin 
    if (spaces is null) then
      pljson_printer.gs_pretty_print_list(json_list, false, buf, chars_per_line, erase_clob);
    else
      pljson_printer.gs_pretty_print_list(json_list, spaces, buf, chars_per_line, erase_clob);
    end if;
  end;
  
  -- procedure gs_print(json_list pljson_list, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as
  --   my_clob clob;
  -- begin 
  --   mog_dbe_lob.create_temporary(my_clob, true);
  --   if (chars_per_line>32512) then
  --       pljson_printer.gs_pretty_print_list(json_list, spaces, my_clob, 32512);
  --   else
  --       pljson_printer.gs_pretty_print_list(json_list, spaces, my_clob, chars_per_line);
  --   end if;
  --   pljson_printer.gs_dbms_output_clob(my_clob, pljson_printer.newline_char, jsonp);
  -- end;

  procedure gs_print(json_list pljson_list, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as
    my_clob clob;
    my_bufstr varchar2;
  begin 
    mog_dbe_lob.create_temporary(my_clob, true);
    if (chars_per_line>32512) then
        my_bufstr := pljson_printer.gs_pretty_print_list(json_list, spaces, 32512);
    else
        my_bufstr := pljson_printer.gs_pretty_print_list(json_list, spaces, chars_per_line);
    end if;
    mog_dbe_lob.append(my_clob, my_bufstr);
    pljson_printer.gs_dbms_output_clob(my_clob, pljson_printer.newline_char, jsonp);
  end;
  
  procedure htp(json_list pljson_list, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as
    my_clob clob;
  begin 
    mog_dbe_lob.create_temporary(my_clob, true);
    pljson_printer.gs_pretty_print_list(json_list, spaces, my_clob, chars_per_line);
    pljson_printer.htp_output_clob(my_clob, jsonp);
  end;
  
  /* json path */
  function gs_path(json_list pljson_list, json_path varchar2, base number default 1) return pljson_value as
    cp pljson_list;
    ret pljson_value;
  begin
    cp := json_list;
    ret = pljson_ext.gs_get_json_value(pljson.gs_pljson(cp), json_path, base);
    return ret;
  end;
    
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem pljson_value, base number default 1) as
    objlist pljson;
    jp pljson_list;
  begin
    jp := pljson_ext.gs_parsePath(json_path, base);
    while (pljson_value.gs_get_number(pljson_list.gs_head(jp)) > pljson_list.gs_count(json_list)) loop
      gs_append(json_list, pljson_value.gs_pljson_value());
    end loop;
    objlist := pljson.gs_pljson(json_list);
    pljson_ext.gs_put(objlist, json_path, elem, base);
    json_list := pljson.gs_get_values(objlist);
  end;
  
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem varchar2, base number default 1) as
    objlist pljson;
    jp pljson_list;
  begin
    jp := pljson_ext.gs_parsePath(json_path, base);
    while (pljson_value.gs_get_number(pljson_list.gs_head(jp)) > pljson_list.gs_count(json_list)) loop
      gs_append(json_list, pljson_value.gs_pljson_value());
    end loop;
    objlist := pljson.gs_pljson(json_list);
    pljson_ext.gs_put(objlist, json_path, elem, base);
    json_list := pljson.gs_get_values(objlist);
  end;
  
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem clob, base number default 1) as
    objlist pljson;
    jp pljson_list;
  begin
    jp := pljson_ext.gs_parsePath(json_path, base);
    while (pljson_value.gs_get_number(pljson_list.gs_head(jp)) > pljson_list.gs_count(json_list)) loop
      gs_append(json_list, pljson_value.gs_pljson_value());
    end loop;
    objlist := pljson.gs_pljson(json_list);
    pljson_ext.gs_put(objlist, json_path, elem, base);
    json_list := pljson.gs_get_values(objlist);
  end;
  
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem number, base number default 1) as
    objlist pljson;
    jp pljson_list;
  begin
    jp := pljson_ext.gs_parsePath(json_path, base);
    while (pljson_value.gs_get_number(pljson_list.gs_head(jp)) > pljson_list.gs_count(json_list)) loop
      gs_append(json_list, pljson_value.gs_pljson_value());
    end loop;
    objlist := pljson.gs_pljson(json_list);
    if (elem is null) then
      pljson_ext.gs_put(objlist, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(objlist, json_path, elem, base);
    end if;
    json_list := pljson.gs_get_values(objlist);
  end;
  
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem binary_double, base number default 1) as
    objlist pljson;
    jp pljson_list;
  begin
    jp := pljson_ext.gs_parsePath(json_path, base);
    while (pljson_value.gs_get_number(pljson_list.gs_head(jp)) > pljson_list.gs_count(json_list)) loop
      gs_append(json_list, pljson_value.gs_pljson_value());
    end loop;
    objlist := pljson.gs_pljson(json_list);
    if (elem is null) then
      pljson_ext.gs_put(objlist, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(objlist, json_path, elem, base);
    end if;
    json_list := pljson.gs_get_values(objlist);
  end;
  
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem boolean, base number default 1) as
    objlist pljson;
    jp pljson_list;
  begin
    jp := pljson_ext.gs_parsePath(json_path, base);
    while (pljson_value.gs_get_number(pljson_list.gs_head(jp)) > pljson_list.gs_count(json_list)) loop
      gs_append(json_list, pljson_value.gs_pljson_value());
    end loop;
    objlist := pljson.gs_pljson(json_list);
    if (elem is null) then
      pljson_ext.gs_put(objlist, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(objlist, json_path, elem, base);
    end if;
    json_list := pljson.gs_get_values(objlist);
  end;
  
  procedure gs_path_put(json_list inout pljson_list, json_path varchar2, elem pljson_list, base number default 1) as 
    objlist pljson;
    jp pljson_list;
  begin
    jp := pljson_ext.gs_parsePath(json_path, base);
    while (pljson_value.gs_get_number(pljson_list.gs_head(jp)) > pljson_list.gs_count(json_list)) loop
      pljson_list.gs_append(json_list, pljson_value.gs_pljson_value());
    end loop;
    objlist := pljson.gs_pljson(json_list);
    if (elem is null) then
      pljson_ext.gs_put(objlist, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(objlist, json_path, elem, base);
    end if;
    json_list := pljson.gs_get_values(objlist);
  end;

  /* json path_remove */
  procedure gs_path_remove(json_list inout pljson_list, json_path varchar2, base number default 1) as
    objlist pljson;
  begin
    objlist := pljson.gs_pljson(json_list);
    pljson_ext.gs_remove(objlist, json_path, base);
    json_list := pljson.gs_get_values(objlist);
  end;

end pljson_list;
/

create or replace package body pljson as

  function gs_pljson() return pljson as
    pj pljson;
  begin 
    pj.check_for_duplicate := 1;
    return pj;
  end;
  
   function gs_pljson(str varchar2) return pljson as
    pj pljson;
  begin 
    pj := pljson_parser.gs_parser(str);
    pj.check_for_duplicate := 1;
    return pj;
  end;
  
   function gs_pljson(str clob) return pljson as
   pj pljson;
  begin 
    pj := pljson_parser.gs_parser(str);
    pj.check_for_duplicate := 1;
    return pj;
  end;
  
  function gs_pljson(str blob, charset varchar2 default 'UTF8') return pljson as
    pj pljson;
    c_str clob;
  begin
    pljson_ext.gs_blob2clob(str, c_str, charset);
    pj := pljson_parser.gs_parser(c_str);
    pj.check_for_duplicate := 1;
    -- dbms_lob.freetemporary(c_str); 
    return pj;
  end;
  
  function gs_pljson(str_array varchar2[]) return pljson as
    pj pljson;
    new_pair boolean := True;
    pair_name varchar2(32767);
    pair_value varchar2(32767);
  begin
    pj.check_for_duplicate := 1;
    for i in str_array.FIRST .. str_array.LAST loop
      if new_pair then
        pair_name := str_array[i];
        new_pair := False;
      else
        pair_value := str_array[i];
        gs_put(pj, pair_name, pair_value);
        new_pair := True;
      end if;
    end loop; 
    return pj;
  end;
  
  function gs_pljson(elem pljson_value) return pljson as
    pj pljson;
  begin 
    -- self := treat(elem.object_or_array as pljson);
    pj := elem.obj;
    return pj;
  end;
  
  function gs_pljson(l pljson_list) return pljson as
    pj pljson;
    temp pljson_value;
  begin 
    for i in 1 .. pljson_list.gs_count(l) loop
      temp = l.pljson_list_data[i];
      if(temp.mapname is null or temp.mapname like 'row%') then
      temp.mapname := 'row'||i;
      end if;
      temp.mapindx := i;
    end loop;

    pj.pljson_list_data := l.pljson_list_data;
    pj.check_for_duplicate := 1;
    return pj;
  end;
  
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value pljson_value, _position integer default null) as
    insert_value pljson_value;
    indx integer; 
    x number;
    temp pljson_value;
  begin

    insert_value := pair_value;
    if insert_value is null then
      insert_value := pljson_value.gs_pljson_value();
    end if;
    insert_value.mapname := pair_name;
    if (pj.check_for_duplicate = 1) then 
      temp := pljson.gs_get(pj, pair_name); 
    else 
      temp := null; 
    end if;
    
    if (temp is not null) then
      insert_value.mapindx := temp.mapindx;
      pj.pljson_list_data[temp.mapindx] := insert_value;
      return;
    elsif (_position is null or _position > pljson.gs_count(pj)) then
      --insert at the end of the list
      pj.pljson_list_data.extend(1);
      insert_value.mapindx := pj.pljson_list_data.count;
      pj.pljson_list_data[pj.pljson_list_data.count] := insert_value;
    elsif (_position < 2) then
      --insert at the start of the list
      indx := pj.pljson_list_data.last;
      pj.pljson_list_data.extend;
      loop
        exit when indx is null;
        temp := pj.pljson_list_data[indx];
        temp.mapindx := indx+1;
        pj.pljson_list_data[temp.mapindx] := temp;
        indx := pj.pljson_list_data.prior(indx);
      end loop;
      insert_value.mapindx := 1;
      pj.pljson_list_data[1] := insert_value;
    else
      --insert somewhere in the list
      indx := pj.pljson_list_data.last;
      pj.pljson_list_data.extend;
      loop
        temp := pj.pljson_list_data[indx];
        temp.mapindx := indx + 1;
        pj.pljson_list_data[temp.mapindx] := temp;
        exit when indx = _position;
        indx := pj.pljson_list_data.prior(indx);
      end loop;
      insert_value.mapindx := _position;
      pj.pljson_list_data[_position] := insert_value;
    end if;
  end;

  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value varchar2, _position integer default null) as
  begin 
    gs_put(pj, pair_name, pljson_value.gs_pljson_value(pair_value), _position);
  end;
    
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value clob, _position integer default null) as
  begin 
    gs_put(pj, pair_name, pljson_value.gs_pljson_value(pair_value), _position);
  end;
    
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value number, _position integer default null) as
  begin 
    if (pair_value is null) then
      gs_put(pj, pair_name, pljson_value.gs_pljson_value(), _position);
    else
      gs_put(pj, pair_name, pljson_value.gs_pljson_value(pair_value), _position);
    end if;
  end;
    
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value binary_double, _position integer default null) as
  begin 
    if (pair_value is null) then
      gs_put(pj, pair_name, pljson_value.gs_pljson_value(), _position);
    else
      gs_put(pj, pair_name, pljson_value.gs_pljson_value(pair_value), _position);
    end if;
  end;
    
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value boolean, _position integer default null) as
  begin 
    if (pair_value is null) then
      gs_put(pj, pair_name, pljson_value.gs_pljson_value(), _position);
    else
      gs_put(pj, pair_name, pljson_value.gs_pljson_value(pair_value), _position);
    end if;
  end;
    
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value pljson, _position integer default null) as
  begin 
    if (pair_value is null) then
      gs_put(pj, pair_name, pljson_value.gs_pljson_value(), _position);
    else
      gs_put(pj, pair_name, pljson.gs_to_json_value(pair_value), _position);
    end if;
  end;
    
  procedure gs_put(pj inout pljson, pair_name varchar2, pair_value pljson_list, _position integer default null) as
  begin 
    if (pair_value is null) then
      gs_put(pj, pair_name, pljson_value.gs_pljson_value(), _position);
    else
      gs_put(pj, pair_name, pljson_list.gs_to_json_value(pair_value), _position);
    end if;
  end;

  procedure gs_remove(pj pljson, pair_name varchar2) as
    temp pljson_value;
    indx integer;
  begin
    temp := pljson.gs_get(pj, pair_name);
    if (temp is null) then 
      return; 
    end if;
    indx := pj.pljson_list_data.next(temp.mapindx);
    loop
      exit when indx is null;
      exit when indx == arr_length(pj.pljson_list_data);
      pj.pljson_list_data[indx].mapindx := indx - 1;
      pj.pljson_list_data[indx-1] := pj.pljson_list_data[indx];
      indx := pj.pljson_list_data.next(indx);
    end loop;
    pj.pljson_list_data.trim(1);
  end;
  
  function gs_count(pj pljson) return number as
  begin 
    return pj.pljson_list_data.count;
  end;

  function gs_get(pj pljson, pair_name varchar2) return pljson_value as
    indx integer;
    ret pljson_value;
  begin
    indx := pj.pljson_list_data.first;
    loop
      exit when indx is null;
      if (pair_name is null and pj.pljson_list_data[indx].mapname is null) then 
        ret = pj.pljson_list_data[indx];
        return ret;
      end if;
      if (pj.pljson_list_data[indx].mapname = pair_name) then 
        ret = pj.pljson_list_data[indx];
        return ret;
      end if;
      indx := pj.pljson_list_data.next(indx);
    end loop;
    return null;
  end;

  function gs_get_string(pj pljson, pair_name varchar2) return varchar2 as
    elem pljson_value;
    ret varchar2;
  begin 
    elem := pljson.gs_get(pj, pair_name);
    ret = pljson_value.gs_get_string(elem);
    return ret;
  end;
     
  function gs_get_clob(pj pljson, pair_name varchar2) return clob as
    elem pljson_value;
    ret clob;
  begin 
    elem := pljson.gs_get(pj, pair_name);
    ret = pljson_value.gs_get_clob(elem);
    return ret;
  end;
     
  function gs_get_number(pj pljson, pair_name varchar2) return number as
    elem pljson_value;
    ret number;
  begin 
    elem := pljson.gs_get(pj, pair_name);
    ret = pljson_value.gs_get_number(elem);
    return ret;
  end;
     
  function gs_get_double(pj pljson, pair_name varchar2) return binary_double as
    elem pljson_value;
    ret binary_double;
  begin 
    elem := pljson.gs_get(pj, pair_name);
    ret = pljson_value.gs_get_double(elem);
    return ret;
  end;
     
  function gs_get_bool(pj pljson, pair_name varchar2) return boolean as
    elem pljson_value;
    ret boolean;
  begin 
    elem := pljson.gs_get(pj, pair_name);
    ret = pljson_value.gs_get_bool(elem);
    return ret;
  end;
     
  function gs_get_pljson(pj pljson, pair_name varchar2) return pljson as
    elem pljson_value;
    ret pljson;
  begin
    elem := pljson.gs_get(pj, pair_name);
    -- return treat(elem.object_or_array as pljson);
    return ret;
  end;
     
  function gs_get_pljson_list(pj pljson, pair_name varchar2) return pljson_list as
    elem pljson_value;
    ret pljson_list;
  begin
    elem := pljson.gs_get(pj, pair_name);
    -- return treat(elem.object_or_array as pljson);
    return ret;
    end;
     
  function gs_get(pj pljson, _position integer) return pljson_value as
    ret pljson_value;
  begin 
    if (pljson.gs_count(pj) >= _position and _position > 0) then
      ret = pj.pljson_list_data[_position];
      return ret;
    end if;
    return null; -- do not throw error, just return null
  end;
     
  function gs_index_of(pj pljson, pair_name varchar2) return number as
    indx integer;
  begin
    indx := pj.pljson_list_data.first;
    loop
      exit when indx is null;
      if (pair_name is null and pj.pljson_list_data[indx].mapname is null) then 
        return indx; 
      end if;
      if (pj.pljson_list_data[indx].mapname = pair_name) then 
        return indx; 
      end if;
      indx := pj.pljson_list_data.next(indx);
    end loop;
    return -1;
  end;
     
  function gs_exist(pj pljson, pair_name varchar2) return boolean as
  begin 
    return (pljson.gs_get(pj, pair_name) is not null);
  end;
     
  function gs_to_json_value(pj pljson) return pljson_value as
    ret pljson_value;
  begin 
    ret = pljson_value.gs_pljson_value(pj);
    return ret;
  end;
   
  procedure gs_check_duplicate(pj inout pljson, v_set boolean) as
  begin 
    if (v_set) then
      pj.check_for_duplicate := 1;
    else
      pj.check_for_duplicate := 0;
    end if;
  end;
    
  procedure gs_remove_duplicates(pj inout pljson) as
  begin 
    pljson_parser.gs_remove_duplicates(pj);
  end;
    
  function gs_to_char(pj pljson, spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin 
    if(spaces is null) then
      return pljson_printer.gs_pretty_print(pj, chars_per_line);
    else
      return pljson_printer.gs_pretty_print(pj, spaces, chars_per_line);
    end if;
  end;
 
  procedure gs_to_clob(pj pljson, buf inout clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  begin 
    if(spaces is null) then
      pljson_printer.gs_pretty_print(pj, false, buf, chars_per_line, erase_clob);
    else
      pljson_printer.gs_pretty_print(pj, spaces, buf, chars_per_line, erase_clob);
    end if;
  end;

  -- procedure gs_print(pj pljson, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as
  --   my_clob clob;
  -- begin
  --   mog_dbe_lob.create_temporary(my_clob, true);
  --   if (chars_per_line>32512) then
  --     pljson_printer.gs_pretty_print(pj, spaces, my_clob, 32512);
  --   else 
  --     pljson_printer.gs_pretty_print(pj, spaces, my_clob, chars_per_line);
  --   end if;
  --   pljson_printer.gs_dbms_output_clob(my_clob, pljson_printer.newline_char, jsonp);
  -- end;

  procedure gs_print(pj pljson, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as
    my_clob clob;
    my_bufstr varchar2;
  begin
    mog_dbe_lob.create_temporary(my_clob, true);
    if (chars_per_line>32512) then
      my_bufstr := pljson_printer.gs_pretty_print(pj, spaces, 32512);
    else 
      my_bufstr := pljson_printer.gs_pretty_print(pj, spaces, chars_per_line);
    end if;
    mog_dbe_lob.append(my_clob,my_bufstr);
    pljson_printer.gs_dbms_output_clob(my_clob, pljson_printer.newline_char, jsonp);
  end;
  
  procedure htp(pj pljson, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as
    my_clob clob;
  begin
    mog_dbe_lob.create_temporary(my_clob, true);
    pljson_printer.gs_pretty_print(pj, spaces, my_clob, chars_per_line);
    pljson_printer.htp_output_clob(my_clob, jsonp);
  end;
    
  function gs_path(pj pljson, json_path varchar2, base number default 1) return pljson_value as
    ret pljson_value;
  begin 
    ret = pljson_ext.gs_get_json_value(pj, json_path, base);
    return ret;
  end;
    
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem pljson_value, base number default 1) as
  begin 
    pljson_ext.gs_put(pj, json_path, elem, base);
  end;
  
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem varchar2, base number default 1) as
  begin 
    pljson_ext.gs_put(pj, json_path, elem, base);
  end;
  
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem clob, base number default 1) as
  begin 
    pljson_ext.gs_put(pj, json_path, elem, base);
  end;
  
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem number, base number default 1) as
  begin 
    if (elem is null) then
      pljson_ext.gs_put(pj, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(pj, json_path, elem, base);
    end if;
  end;
  
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem binary_double, base number default 1) as
  begin 
    if (elem is null) then
      pljson_ext.gs_put(pj, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(pj, json_path, elem, base);
    end if;
  end;
  
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem boolean, base number default 1) as
  begin 
    if (elem is null) then
      pljson_ext.gs_put(pj, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(pj, json_path, elem, base);
    end if;
  end;
  
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem pljson, base number default 1) as
  begin 
      if (elem is null) then
      pljson_ext.gs_put(pj, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(pj, json_path, elem, base);
    end if;
  end;
  
  procedure gs_path_put(pj inout pljson, json_path varchar2, elem pljson_list, base number default 1) as
  begin 
    if (elem is null) then
      pljson_ext.gs_put(pj, json_path, pljson_value.gs_pljson_value(), base);
    else
      pljson_ext.gs_put(pj, json_path, elem, base);
    end if;
  end;

  procedure gs_path_remove(pj inout pljson, json_path varchar2, base number default 1) as
  begin 
    pljson_ext.gs_remove(pj, json_path, base);
  end;
  
  function gs_get_keys(pj pljson) return pljson_list as
    keys pljson_list;
    indx integer;
  begin
    keys := pljson_list.gs_pljson_list();
    indx := pj.pljson_list_data.first;
    loop
      exit when indx is null;
      pljson_list.gs_append(keys, pj.pljson_list_data[indx].mapname);
      indx := pj.pljson_list_data.next(indx);
    end loop;
    return keys;
    end;
    
  function gs_get_values(pj pljson) return pljson_list as
    vals pljson_list;
  begin
    vals := pljson_list.gs_pljson_list();
    vals.pljson_list_data := pj.pljson_list_data;
    return vals;
  end;
  
end pljson;
/

reset current_schema;

grant usage ON schema dbe_PLJSON TO public;

set current_schema=dbe_PLJSON;

drop type t1 cascade;
drop type tt1 cascade;

create type t1 as ( a int  );
create type tt1 as ( b t1[]  );
alter type t1 add attribute arr tt1;

create type t2 as ( a int  );
create type tt2 as (pljson_list_data t2[]);
alter type t2 add attribute arr tt2;

declare
obj pljson;
begin
obj := pljson.gs_pljson('{"a": true }');
pljson.gs_print(obj);
obj := pljson.gs_pljson('
{
"a": null,
"b": 12.243,
"c": 2e-3,
"d": [true, false, "abdc", [1,2,3]],
"e": [3, {"e2":3}],
"f": {"f2":true}
}');
pljson.gs_print(obj);
pljson.gs_print(obj, false);
end;
/

reset current_schema;

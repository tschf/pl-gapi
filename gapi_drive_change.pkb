/*******************************************************************

Copyright (C) Trent Schafer 2014

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

*******************************************************************/

create or replace
package body gapi_drive_change
as

    function get_change_from_json(
        p_change_json in CLOB) return t_change
    AS
        l_change t_change;
        l_json JSON;
    BEGIN
    
        l_json := JSON(p_change_json);
        
        l_change.id := json_ext.get_string(l_json, 'id');
        l_change.file_id := json_ext.get_string(l_json, 'fileId');
        l_change.self_link := json_ext.get_string(l_json, 'selfLink');
        l_change.deleted := json_ext.get_bool(l_json, 'deleted');
        l_change.modification_date :=   
            gapi.get_local_timestamp(
                json_ext.get_string(l_json, 'modificationDate') 
            );
        
        return l_change;
    
    END get_change_from_json;

    /*
    
        get action: https://developers.google.com/drive/v2/reference/changes/get
    
    */
    function get_change(
        p_access_token in varchar2
      , p_change_id in varchar2) return t_change
    AS
        l_change t_change;
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/changes/#ID#';
        l_response CLOB;
    BEGIN
    
        l_request_url := replace(l_request_url, '#ID#', p_change_id);
    
        l_response :=
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'GET'
              , p_payload => NULL);    
              
        return get_change_from_json(l_response);
    
    END get_change;
    
    /*
    
        list action: https://developers.google.com/drive/v2/reference/changes/list
    
    */
    function list_changes(
        p_access_token in varchar2) return t_change_list
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/changes';
        l_response CLOB;
        l_response_json JSON;
        
        l_json_change_list JSON_LIST;
        
        
        l_cur_change t_change;
        l_change_list t_change_list;
    BEGIN
    
        l_response :=
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'GET'
              , p_payload => NULL);    
              
        l_response_json := JSON(l_response);
              
        l_json_change_list := JSON_EXT.get_json_list(l_Response_json, 'items');
      
        for i in 1..l_json_change_list.COUNT
        LOOP
            
            l_cur_change := get_change_from_json(l_json_change_list.get(i).to_char);
            l_change_list(i) := l_cur_change;
            
        END LOOP;      
        
        return l_change_list;
              
    END list_changes;    
    
    function list_changes_sql(
        p_access_token in varchar2) return t_change_list_sql pipelined
    AS
        l_change_sql t_change_sql;
        l_change_list t_change_list;
    BEGIN
    
        l_change_list := list_changeS(p_access_token);
        
        for i in 1..l_change_list.COUNT
        LOOP
        
            l_change_sql.kind               := l_change_list(i).kind;
            l_change_sql.id                 := l_change_list(i).id;
            l_change_sql.file_id            := l_change_list(i).file_id;
            l_change_sql.self_link          := l_change_list(i).self_link;
            l_change_sql.deleted            := case when l_change_list(i).deleted then GAPI.GC_TRUE else GAPI.GC_FALSE end;
            l_change_sql.modification_date  := l_change_list(i).modification_date;
            
            pipe row (l_change_sql);
            
            l_change_sql := NULL;
        
        END LOOP;
    
    END list_changes_sql;    

end gapi_drive_change;
/

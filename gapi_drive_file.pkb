/*******************************************************************

Copyright (C) Trent Schafer 2013-2014

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
package body gapi_drive_file
as

    /*
    
        Copy action: https://developers.google.com/drive/v2/reference/files/copy
    
    */

    function copy_file(
        p_file_id in varchar2
      , p_title in varchar2
      , p_access_token in varchar2) return varchar2
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files/#ID#/copy';
        
        l_payload JSON;
        
        l_response CLOB;
        l_response_json JSON;
        
    BEGIN
        l_request_url := replace(l_request_url, '#ID#', p_file_id);
        
        l_payload := JSON;
        
        l_payload.put('title', p_title);
        
        l_response := 
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_Request_url
              , p_method => 'POST'
              , p_payload => l_payload.to_char
            );
        
        l_response_json := JSON(l_response);
        
        return JSON_EXT.GET_STRING(l_response_json, 'id');
    
    END copy_file;
    
    
    /*
    
        delete action: https://developers.google.com/drive/v2/reference/files/delete
    
    */    
    
    procedure delete_file(
        p_file_id in varchar2
      , p_Access_token in varchar2)
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files/#ID#';
        
        l_response CLOB;
    BEGIN
    
        l_request_url := replace(l_request_url, '#ID#', p_file_id);
        
        l_response :=
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'DELETE'
              , p_payload => NULL
            );
            
        --response is NULL if successful            
    
    END delete_file;    
    
    function get_file_from_json(
        p_file_json in CLOB) return t_file
    AS
        l_return_file t_file;
        l_json JSON;
        l_labels JSON;
    BEGIN
    
        l_json := JSON(p_file_json);
        
        l_return_file.id := json_ext.get_string(l_json, 'id');
        l_return_file.self_link := json_ext.get_string(l_json, 'selfLink');
        l_return_file.alternate_link := json_ext.get_string(l_json, 'alternateLink');
        l_return_file.embed_link := json_ext.get_string(l_json, 'embedLink');
        l_return_file.icon_link := json_ext.get_string(l_json, 'iconLink');
        l_return_file.thumbnail_link := json_ext.get_string(l_json, 'thumbnailLink');
        l_return_file.title := json_ext.get_string(l_json, 'title');
        l_return_file.description := json_ext.get_string(l_json, 'description');
        l_return_file.mime_type := json_ext.get_string(l_json, 'mimeType');
        l_return_file.created_date := json_ext.get_string(l_json, 'createDate');
        l_return_file.modified_date := json_ext.get_string(l_json, 'modifiedDate');
        l_return_file.modified_by_me_date := json_ext.get_string(l_json, 'modifiedByMeDate');
        l_return_file.last_viewed_by_me_date := json_ext.get_string(l_json, 'lastViewedByMeDate');
        l_return_file.quota_bytes_used := json_ext.get_string(l_json, 'quotaBytesUsed');
        l_return_file.last_modifying_user_name := json_ext.get_string(l_json, 'lastModifyingUserName');
        l_return_file.editable := json_ext.get_bool(l_json, 'editable');
        l_return_file.copyable := json_ext.get_bool(l_json, 'copyable');
        l_return_file.writers_can_share := json_ext.get_bool(l_json, 'writersCanShare');
        l_return_file.shared := json_ext.get_bool(l_json, 'shared');
        l_return_file.app_data_contents := json_ext.get_bool(l_json, 'appDataContents');
        
        --Labels
        l_labels := JSON_EXT.get_json(l_json, 'labels');
        l_return_file.starred := json_ext.get_bool(l_labels, 'starred');
        l_return_file.hidden := json_ext.get_bool(l_labels, 'hidden');
        l_return_file.trashed := json_ext.get_bool(l_labels, 'trashed');
        l_return_file.restricted := json_ext.get_bool(l_labels, 'restricted');
        l_return_file.viewed := json_ext.get_bool(l_labels, 'viewed');

  
        return l_return_file;
    END get_file_from_json;
    
    /*
    
        get action: https://developers.google.com/drive/v2/reference/files/get  
    
    */
    
    function get_file(
        p_file_id in varchar2
      , p_access_token in varchar2) return t_file
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files/#ID#';
        l_response CLOB;
    
        l_file t_file;
    BEGIN
        
        l_request_url := replace(l_request_url, '#ID#', p_file_id);
    
        l_response :=
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'GET'
              , p_payload => NULL);
              
        l_file := get_file_from_json(l_response);
        
        
    
        return file;
    END get_file;    
    
    /*
    
        list action: https://developers.google.com/drive/v2/reference/files/list
        
    */
    
    function list_files(
        p_max_results in NUMBER
      , p_query in varchar2
      , p_access_token in varchar2) return t_file_list
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files';
        
        l_response CLOB;
        l_response_json JSON;
        l_json_file_list JSON_LIST;
        l_cur_file t_file;
        
        l_file_list t_file_list;
    BEGIN
    
        l_request_url := l_request_url || '?maxResults='||p_max_results||'&q='||p_query;
        l_request_url := utl_url.escape(l_request_url);
        
        l_response :=
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'GET'
              , p_payload => NULL);
              
              
        l_response_json := JSON(l_response);
        
        l_json_file_list := JSON_EXT.get_json_list(l_Response_json, 'items');
        
        for i in 1..l_json_file_list.COUNT
        LOOP
            
            l_cur_file := get_file_from_json(l_json_file_list.get(i).to_char);
            l_file_list(i) := l_cur_file;
            
        END LOOP;
              
        
        return l_file_list;
    
    END list_files;
    
    /*
    
        trash action: https://developers.google.com/drive/v2/reference/files/trash
        
    */
    
    procedure trash_file(
        p_file_id in varchar2
      , p_access_token in varchar2)
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files/#ID#/trash';
        
        l_response CLOB;
    BEGIN
        l_request_url := replace(l_request_url, '#ID#', p_file_id);
        
        l_response :=
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'POST'
              , p_payload => NULL
            );
            
    END trash_file;
    
    /*
    
        untrash action: https://developers.google.com/drive/v2/reference/files/untrash
        
    */
      
    procedure untrash_file(
        p_file_id in varchar2
      , p_access_token in varchar2)
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files/#ID#/untrash';
        
        l_response CLOB;
    BEGIN
    
        l_request_url := replace(l_Request_url, '#ID#', p_file_id);
        
        l_response :=
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'POST'
              , p_payload => NULL
            );        
    
    END untrash_file;

    /*
    
      insert action: https://developers.google.com/drive/v2/reference/files/insert
      See also: https://developers.google.com/drive/web/folder
    
    */

    function create_folder(
        p_folder_name in varchar2
      , p_access_token in varchar2) return varchar2
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files';
    
        l_payload JSON;
        l_response CLOB;
        l_response_JSON JSON;
    BEGIN
        l_payload := JSON;
        
        l_payload.put('mimeType', 'application/vnd.google-apps.folder');
        l_payload.put('title', p_folder_name);
        
        l_response := gapi_core.authorized_request(
            p_access_token => p_access_token
          , p_url => l_request_url
          , p_method => 'POST'
          , p_payload => l_payload.to_char
        );
        
        l_response_JSON := JSON(l_response);
      
        return JSON_EXT.GET_STRING(l_response_JSON, 'id');    
    END create_folder;
        
        
    /*
    
      insert action: https://developers.google.com/drive/v2/reference/files/insert
      
    
    */
            
    procedure create_file(
        p_data in BLOB
      , p_mime_type in varchar2
      , p_file_name in varchar2
      , p_folder_id in varchar2
      , p_access_token in varchar2)
    AS
        l_insert_url varchar2(200) := 'https://www.googleapis.com/upload/drive/v2/files?uploadType=media';
        l_update_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files/#ID#';
        l_response CLOB;
        l_response_json JSON;
        l_update_json JSON;
        l_parent JSON_LIST;
        l_parent_id JSON;
        l_file_id varchar2(200);    
    BEGIN
        
        l_response := gapi_core.authorized_request(
            p_access_token => p_access_token
          , p_url => l_insert_url
          , p_payload => p_data
          , p_content_type => p_mime_type);        
          

        l_response_json := JSON(l_response);
    
        l_file_id := json_ext.get_string(l_response_json, 'id');
    
        l_update_url := replace(l_updatE_url, '#ID#', l_file_id);
    
        l_update_json := JSON;
        l_update_json.put('title', p_file_name);
    
        l_parent_id := JSON;
        JSON.put(l_parent_id, 'id', p_folder_id);
    
        l_parent := JSON_LIST;
        l_parent.append(l_parent_id.to_json_value);
    
        JSON.put(l_update_json, 'parents', l_parent);
    
        l_response := gapi_core.authorized_request(
            p_access_token => p_access_token
          , p_url => l_update_url
          , p_payload => l_update_json.to_char
          , p_method => 'PUT');          
        
    END create_file;

    /*
    
        update (patch) action: https://developers.google.com/drive/v2/reference/files/patch
    
    */
    
    procedure update_file(
        p_file_id in varchar2
      , p_title in varchar2 default NULL
      , p_description in varchar2 default NULL
      , p_folder_id in varchar2 default NULL
      , p_access_token in varchar2)
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files/#ID#';
        
        l_payload JSON;
        l_folder JSON;
        l_folder_list JSON_LIST;
        
        l_response CLOB;
    BEGIN
    
        l_Request_url := replace(l_Request_url, '#ID#', p_file_id);
    
        l_payload := JSON;
        
        if p_title is not null
        then
            l_payload.put('title', p_title);
        end if;
        
        if p_description is not null
        then
            l_payload.put('description', p_description);
        end if;
        
        if p_folder_id is not null
        then
            l_folder := JSON;
            l_folder.put('id', p_folder_id);
            
            l_folder_list := JSON_LIST;
            l_folder_list.append(l_folder.to_json_value);
            
            l_payload.put('parents', l_folder_list);
        end if;    
        
        l_response :=
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_payload => l_payload.to_char
              , p_method => 'PATCH'
            );
        
           
    END update_file;    
    
    /*
        touch action: https://developers.google.com/drive/v2/reference/files/touch
    */
    
    procedure touch_file(
        p_file_id in varchar2
      , p_access_token in varchar2)
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/files/#ID#/touch';
        
        l_response CLOB;
    BEGIN
    
        l_request_url := replace(l_request_url, '#ID#', p_file_id);
        
        l_response :=
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_payload => NULL
              , p_method => 'POST');
    
    END touch_file;

end gapi_drive_file;
/

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
package body gapi_drive
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

end gapi_drive;
/

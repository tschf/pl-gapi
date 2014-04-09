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

end gapi_drive;

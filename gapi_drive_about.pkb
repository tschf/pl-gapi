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
package body gapi_drive_about
as

    function get_about_from_json(
        p_file_JSON in CLOB) return t_about
    AS
        l_return_about t_about;
    
        l_json JSON;
    BEGIN
    
        l_json := JSON(p_file_JSON);
        
        l_return_about.self_link  := json_ext.get_String(l_json, 'selfLink');
        l_return_about.name  := json_ext.get_String(l_json, 'name');
        l_return_about.quota_bytes_total  := json_ext.get_String(l_json, 'quotaBytesTotal');
        l_return_about.quota_bytes_used  := json_ext.get_String(l_json, 'quotaBytesUsed');
        l_return_about.quota_bytes_used_agg  := json_ext.get_String(l_json, 'quotaBytesUsedAggregate');
        l_return_about.quota_bytes_used_trash  := json_ext.get_String(l_json, 'quotaBytesUsedInTrash');
        l_return_about.largest_change_id  := json_ext.get_String(l_json, 'largestChangeId');
        l_return_about.remaining_channel_ids  := json_ext.get_String(l_json, 'remainingChangeIds');
        l_return_about.root_folder_id  := json_ext.get_String(l_json, 'rootFolderId');
        l_return_about.domain_sharing_policy  := json_ext.get_String(l_json, 'domainSharingPolicy');
        l_return_about.permission_id := json_ext.get_String(l_json, 'permissionId');
        
        return l_return_about;        
    
    END get_about_from_json;

    /*
    
        get action: https://developers.google.com/drive/v2/reference/about/get
    
    */

    function get_about(
        p_access_token in varchar2) return t_about
    AS
        l_return t_about;
        
        l_request_url varchar2(200) := 'https://www.googleapis.com/drive/v2/about';
        l_response CLOB;
    BEGIN
    
        l_response :=
            gapi_core.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'GET'
              , p_payload => NULL);
    
        l_return := get_about_from_json(l_Response);
    
        return l_return;
        
    END get_about;

end gapi_drive_about;
/


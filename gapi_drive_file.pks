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
package gapi_drive_file
as

    g_scope_full constant varchar2(50) := 'https://www.googleapis.com/auth/drive';
    
    type t_file is record (
        kind varchar2(20) := 'drive#file'
      , id varchar2(50)
      , self_link varchar2(200)
      , alternate_link varchar2(200)
      , embed_link varchar2(200)
      , icon_link varchar2(200)
      , thumbnail_link varchar2(200)
      , title varchar2(200)
      , description varchar2(4000)
      , mime_type varchar2(200)
      , starred BOOLEAN
      , hidden BOOLEAN
      , trashed BOOLEAN
      , restricted BOOLEAN
      , viewed BOOLEAN
      , parent_id varchar2(50)
      , created_date varchar2(100)
      , modified_date varchar2(100)
      , modified_by_me_date varchar2(100)
      , last_viewed_by_me_date varchar2(100)
      , quota_bytes_used NUMBER
      , last_modifying_user_name varchar2(200)
      , editable BOOLEAN
      , copyable BOOLEAN
      , writers_can_share BOOLEAN
      , shared BOOLEAN
      , app_data_contents BOOLEAN
    );
    
    type t_file_sql is record (
        kind varchar2(20) := 'drive#file'
      , id varchar2(50)
      , self_link varchar2(200)
      , alternate_link varchar2(200)
      , embed_link varchar2(200)
      , icon_link varchar2(200)
      , thumbnail_link varchar2(200)
      , title varchar2(200)
      , description varchar2(4000)
      , mime_type varchar2(200)
      , starred GAPI_CORE.SQL_BOOL
      , hidden GAPI_CORE.SQL_BOOL
      , trashed GAPI_CORE.SQL_BOOL
      , restricted GAPI_CORE.SQL_BOOL
      , viewed GAPI_CORE.SQL_BOOL
      , parent_id varchar2(50)
      , created_date varchar2(100)
      , modified_date varchar2(100)
      , modified_by_me_date varchar2(100)
      , last_viewed_by_me_date varchar2(100)
      , quota_bytes_used NUMBER
      , last_modifying_user_name varchar2(200)
      , editable GAPI_CORE.SQL_BOOL
      , copyable GAPI_CORE.SQL_BOOL
      , writers_can_share GAPI_CORE.SQL_BOOL
      , shared GAPI_CORE.SQL_BOOL
      , app_data_contents GAPI_CORE.SQL_BOOL
    );
    
    type t_file_list is table of t_file index by PLS_INTEGER;
    type t_file_list_sql is table of t_file_Sql;
    
    function copy_file(
        p_file_id in varchar2
      , p_title in varchar2
      , p_access_token in varchar2) return varchar2;
      
    procedure delete_file(
        p_file_id in varchar2
      , p_Access_token in varchar2);
      
    function get_file(
        p_file_id in varchar2
      , p_access_token in varchar2) return t_file;
      
    function list_files(
        p_max_results in NUMBER
      , p_query in varchar2
      , p_access_token in varchar2) return t_file_list;
      
    function list_files_sql(
        p_max_results in NUMBER
      , p_query in varchar2
      , p_access_token in varchar2) return t_file_list_sql pipelined;    
      
    procedure trash_file(
        p_file_id in varchar2
      , p_access_token in varchar2);
      
    procedure untrash_file(
        p_file_id in varchar2
      , p_access_token in varchar2);

    function create_folder(
        p_folder_name in varchar2
      , p_access_token in varchar2) return varchar2;
        
    function create_file(
        p_data in BLOB
      , p_mime_type in varchar2
      , p_file_name in varchar2
      , p_folder_id in varchar2
      , p_access_token in varchar2) return varchar2;
      
    procedure update_file(
        p_file_id in varchar2
      , p_title in varchar2 default NULL
      , p_description in varchar2 default NULL
      , p_folder_id in varchar2 default NULL
      , p_access_token in varchar2);
      
    procedure touch_file(
        p_file_id in varchar2
      , p_access_token in varchar2);
        

end gapi_drive_file;
/

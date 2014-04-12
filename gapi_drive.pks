/*******************************************************************

Copyright (C) Trent Schafer 2013  

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
package gapi_drive
as

    g_scope_full constant varchar2(50) := 'https://www.googleapis.com/auth/drive';
    
    function copy_file(
        p_file_id in varchar2
      , p_title in varchar2
      , p_access_token in varchar2) return varchar2;
      
    procedure delete_file(
        p_file_id in varchar2
      , p_Access_token in varchar2);
      
    procedure trash_file(
        p_file_id in varchar2
      , p_access_token in varchar2);
      
    procedure untrash_file(
        p_file_id in varchar2
      , p_access_token in varchar2);

    function create_folder(
        p_folder_name in varchar2
      , p_access_token in varchar2) return varchar2;
        
    procedure create_file(
        p_data in BLOB
      , p_mime_type in varchar2
      , p_file_name in varchar2
      , p_folder_id in varchar2
      , p_access_token in varchar2);

end gapi_drive;

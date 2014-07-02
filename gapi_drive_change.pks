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
package gapi_drive_change
as

    type t_change is record (
        kind varchar2(20) := 'drive#change'
      , id NUMBER
      , file_id varchar2(200)
      , self_link varchar2(200)
      , deleted BOOLEAN
      , modification_date varchar2(200)
    );
    
    type t_change_sql is record (
        kind varchar2(20) := 'drive#change'
      , id NUMBER
      , file_id varchar2(200)
      , self_link varchar2(200)
      , deleted GAPI.SQL_BOOL
      , modification_date varchar2(200)
    );
    
    type t_change_list is table of t_change index by PLS_INTEGER;
    type t_change_list_sql is table of t_change_sql;
    
    function get_change(
        p_access_token in varchar2
      , p_change_id in varchar2) return t_change;
        
    function list_changes(
        p_access_token in varchar2) return t_change_list;
        
    function list_changes_sql(
        p_access_token in varchar2) return t_change_list_sql pipelined;
        
    
    

end gapi_drive_change;
/

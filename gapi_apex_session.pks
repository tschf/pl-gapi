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
package gapi_apex_session
as

    procedure re_init_session(
        p_session_id in apex_workspace_sessions.apex_session_id%type);
    
    function get_session_username(
        p_session_id in apex_workspace_sessions.apex_session_id%type) return apex_workspace_sessions.user_name%type;
    

end gapi_apex_session;
/

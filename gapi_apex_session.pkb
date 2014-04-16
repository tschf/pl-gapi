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
package body gapi_apex_session
as

    /*
    
        Example used from: http://www.talkapex.com/2012/08/how-to-create-apex-session-in-plsql.html
    
    */
    procedure re_init_session(
        p_session_id in apex_workspace_sessions.apex_session_id%type)
    as
        l_workspace_id apex_applications.workspace_id%type;
        l_cgivar_name owa.vc_arr;
        l_cgivar_val owa.vc_arr;
        
        l_app_id NUMBER := 100;
    begin
        htp.init;
        
        l_cgivar_name(1) := 'REQUEST_PROTOCOL';
        l_cgivar_val(1) := 'HTTP';
        
        owa.init_cgi_env(
            num_params => 1
          , param_name => l_cgivar_name
          , param_val => l_cgivar_val);
        
        select workspace_id
        into l_workspace_id
        from apex_applications
        where application_id = l_app_id;
        
        wwv_flow_api.set_security_group_id (l_workspace_id);
        
        apex_application.g_instance := 1;
        apex_application.g_flow_id := l_app_id;
        apex_application.g_flow_step_id := 1;
        
        apex_custom_auth.post_login(
            p_uname => get_session_username(p_session_id)
          , p_session_id => NULL
          , p_app_page => apex_application.g_flow_id || ':' || 1);
          
        apex_custom_auth.set_session_id(
            p_session_id => p_session_id);
          
    end re_init_session;
    
    function get_session_username(
        p_session_id in apex_workspace_sessions.apex_session_id%type) return apex_workspace_sessions.user_name%type
    as
        l_user_name apex_workspace_sessions.user_name%type;
    begin
    
        select user_name
        into l_user_name
        from apex_workspace_sessions
        where apex_session_id = p_session_id;
        
        return l_user_name;
    
    end get_session_username;

end gapi_apex_session;
/

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
package body gapi_auth
as

    g_client_id varchar2(400) := '';
    g_client_secret varchar2(400) := '';
    
    g_redirect_uri varchar2(400) := 'http://example.com/apex/#SCHEMA#.GAPI_AUTH.CALLBACK';
    g_auth_url varchar2(400) := 'https://accounts.google.com/o/oauth2/auth';
    
    g_token_url varchar2(400) := 'https://accounts.google.com/o/oauth2/token';
    g_token_grant_type varchar2(20) := 'authorization_code';
    
    g_endpoint_url varchar2(400) := 'http://example.com:8888/apex/f?p=100:1:';

    --Refer to docs: https://developers.google.com/accounts/docs/OAuth2WebServer
     function get_authorization_url(
        p_state in varchar2
      , p_scope in varchar2) return varchar2
    AS
    
        l_url_params varchar2(400);
        l_state varchar2(400);
        l_scope varchar2(400);
    BEGIN
    
        l_state := utl_url.unescape(p_state);
        l_scope := utl_url.unescape(p_scope);                      
        
        l_url_params :=  
            'response_type=#RESPONSE_TYPE#&client_id=#CLIENT_ID#&redirect_uri=#REDIRECT_URI#&scope=#SCOPE#&state=#STATE#&access_type=offline&approval_prompt=force';

        l_url_params := replace(l_url_params, '#RESPONSE_TYPE#', 'code');  
        l_url_params := replace(l_url_params, '#CLIENT_ID#', g_client_id);
        l_url_params := replace(l_url_params, '#REDIRECT_URI#', g_redirect_uri);
        l_url_params := replace(l_url_params, '#SCHEMA#', sys_context('userenv','current_schema'));
        l_url_params := replace(l_url_params, '#SCOPE#', p_scope);
        l_url_params := replace(l_url_params, '#STATE#', p_state);
  
        return g_auth_url || '?' || l_url_params;
        
    END get_authorization_url;
      
    procedure callback(
        code in varchar2 default NULL
      , error in varchar2 default NULL
      , state in varchar2)
    AS
        
        l_token_req utl_http.req;
        l_token_res utl_http.resp;
        
        l_token_req_payload varchar2(300);
        
        l_response CLOB;
        l_response_tmp varchar2(1024);
        l_response_json JSON;
        
        l_unescaped_state varchar2(200);
        l_endpoint_url varchar2(200);
    BEGIN
    
        l_token_req_payload := 
            'code=#CODE#&client_id=#CLIENT_ID#&client_secret=#CLIENT_SECRET#&redirect_uri=#REDIRECT_URI#&grant_type=#GRANT_TYPE#';
        
        l_unescaped_state := utl_url.unescape(state);
        l_endpoint_url := g_endpoint_url || l_unescaped_state;
        
        if code is not null then
            l_token_req_payload := replace(l_token_req_payload, '#CODE#', code);
            l_token_req_payload := replace(l_token_req_payload, '#CLIENT_ID#', g_client_id);
            l_token_req_payload := replace(l_token_req_payload, '#CLIENT_SECRET#', g_client_secret);
            l_token_req_payload := replace(l_token_req_payload, '#REDIRECT_URI#', g_redirect_uri);
            l_token_req_payload := replace(l_token_req_payload, '#GRANT_TYPE#', g_token_grant_type);
            l_token_req_payload := replace(l_token_req_payload, '#SCHEMA#', sys_context('userenv','current_schema'));

            utl_http.set_wallet(
                path => gapi_core.get_wallet_path
              , password => gapi_core.get_wallet_password);
      
            l_token_req := utl_http.begin_request(
                url => g_token_url
              , method => 'POST');
  
            utl_http.set_header(
                r => l_token_req
              , name => 'Content-length'
              , value => length(l_token_req_payload));
  
      
            utl_http.set_header(
                r => l_token_req
              , name => 'Content-Type'
              , value => 'application/x-www-form-urlencoded');
  
            utl_http.write_text(
                r => l_token_req
              , data => utl_url.escape(l_token_req_payload));
  
      
            l_token_res := utl_http.get_response(
                r => l_token_req);
  
            BEGIN
  
                LOOP
          
                    utl_http.read_line(
                        r => l_token_res
                      , data => l_response_tmp
                      , remove_crlf => FALSE);
                      
                    l_response := l_response || l_response_tmp;
          
                END LOOP;
      
            EXCEPTION
            WHEN
                UTL_HTTP.END_OF_BODY
                    THEN
            
                        utl_http.end_response(
                            r => l_token_res);
            END;
     
            l_response_json := JSON(l_response);
                     
            
            
        END IF;
        
        owa_util.redirect_url(
            curl => l_endpoint_url);
        
        
    EXCEPTION
    WHEN
        OTHERS
            THEN
                htp.p(utl_http.get_detailed_sqlerrm);
                htp.p(sqlerrm);
                htp.p('<br />Click <a href="' || g_endpoint_url || state || '">here</a> to go back to apex');
    
    END callback;
    
    

end gapi_auth;
/

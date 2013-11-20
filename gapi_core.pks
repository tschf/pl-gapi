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
package gapi_core
as
    
    function authorized_request(
        p_access_token in varchar2
      , p_url in varchar2
      , p_method in varchar2 default 'GET'
      , p_content_type in varchar2 default 'application/json'
      , p_payload in varchar2 default NULL
      , p_wallet_path in varchar2 default NULL
      , p_wallet_password in varchar2 default '') return CLOB;

    function authorized_request(
        p_access_token in varchar2
      , p_url in varchar2
      , p_method in varchar2 default 'POST'
      , p_content_type in varchar2
      , p_payload in BLOB
      , p_wallet_path in varchar2 default NULL
      , p_wallet_password in varchar2 default '') return CLOB;
      
    function get_wallet_path return varchar2;
    procedure set_wallet_path(
        p_path in varchar2);
        
    function get_wallet_password return varchar2;
    procedure set_wallet_password(
        p_password in varchar2);

end gapi_core;

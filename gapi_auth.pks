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
package gapi_auth
as

    procedure begin_auth(
      p_scope                     in varchar2
    , p_return_app                in varchar2
    , p_return_page               in VARCHAR2
    , p_session                   in varchar2
    , p_item_for_refresh_token    in varchar2
    , p_item_for_access_token     in varchar2 default NULL);
    
    function get_authorization_url(
        p_state in varchar2
      , p_scope in varchar2) return varchar2;
      
    procedure callback(
        code in varchar2 default NULL
      , error in varchar2 default NULL
      , state in varchar2);
      
    function get_access_token(
      p_refresh_token in varchar2) return varchar2;

end gapi_auth;
/

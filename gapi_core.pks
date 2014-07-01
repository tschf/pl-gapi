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
package gapi_core
as

    subtype SQL_BOOL is varchar2(5);
    
    GC_TRUE         constant varchar2(5) := 'true';
    GC_FALSE        constant varchar2(5) := 'false';

    procedure set_header(  
        p_seq in NUMBER
      , p_name in varchar2
      , p_value in varchar2);
    
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
        
    function get_timestamp(p_time TIMESTAMP default systimestamp) return varchar2;
    
    function get_local_timestamp(
        p_timestamp in varchar2
      , p_source_time_zone in varchar2 default '+00:00'
      , p_dest_time_zone in varchar2 default sessiontimezone) return timestamp with time zone;

end gapi_core;
/

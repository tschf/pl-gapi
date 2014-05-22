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
package gapi_cal_calendar
as
    
    type t_calendar is record (
        kind varchar2(50) := 'calendar#calendarListEntry'
      , id varchar2(100)
      , summary varchar2(50)
      , description varchar2(512)
      , location varchar2(200)
      , time_zone varchar2(200)
      , summary_override varchar2(50)
      , color_id varchar2(10)
      , background_color varchar2(10)
      , foreground_color varchar2(10)
      , hidden BOOLEAN
      , selected BOOLEAN
      , access_role varchar2(20)
      , primary BOOLEAN
      , deleted BOOLEAN
    );
    
    type t_calendar_sql is record (
        kind varchar2(50) := 'calendar#calendarListEntry'
      , id varchar2(100)
      , summary varchar2(50)
      , description varchar2(512)
      , location varchar2(200)
      , time_zone varchar2(200)
      , summary_override varchar2(50)
      , color_id varchar2(10)
      , background_color varchar2(10)
      , foreground_color varchar2(10)
      , hidden GAPI_CORE.SQL_BOOL
      , selected GAPI_CORE.SQL_BOOL
      , access_role varchar2(20)
      , primary GAPI_CORE.SQL_BOOL
      , deleted GAPI_CORE.SQL_BOOL    
    );
    
    type t_calendar_list is table of t_calendar index by PLS_INTEGER;    
    type t_calendar_list_sql is table of t_calendar_sql;
    
    function list_calendars(
        p_access_token in varchar2
    ) return t_calendar_list;
    
    function list_calendars_sql(
        p_access_token in varchar2
    ) return t_calendar_list_sql pipelined;
    
    function create_calendar(
        p_title in varchar2
      , p_access_token in varchar2) return varchar2;

end gapi_cal_calendar;
/

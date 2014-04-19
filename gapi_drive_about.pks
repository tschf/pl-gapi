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
package gapi_drive_about
as

    type t_about is record (
        kind varchar2(20) := 'drive#about'
      , self_link varchar2(200)
      , name varchar2(200)
      , quota_bytes_total NUMBER
      , quota_bytes_used NUMBER
      , quota_bytes_used_agg NUMBER
      , quota_bytes_used_trash NUMBER
      , largest_change_id NUMBER
      , remaining_channel_ids NUMBER
      , root_folder_id varchar2(200)
      , domain_sharing_policy varchar2(200)
      , permission_id varchar2(200)
    );

    function get_about(
        p_access_token in varchar2) return t_about;

end gapi_drive_about;
/


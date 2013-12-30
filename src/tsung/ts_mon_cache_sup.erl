%%%  This program is free software; you can redistribute it and/or modify
%%%  it under the terms of the GNU General Public License as published by
%%%  the Free Software Foundation; either version 2 of the License, or
%%%  (at your option) any later version.
%%%
%%%  This program is distributed in the hope that it will be useful,
%%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%%  GNU General Public License for more details.
%%%
%%%  You should have received a copy of the GNU General Public License
%%%  along with this program; if not, write to the Free Software
%%%  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
%%%

%%% In addition, as a special exception, you have the permission to
%%% link the code of this program with any library released under
%%% the EPL license and distribute linked combinations including
%%% the two.

-module(ts_mon_cache_sup).
-define(WORKERS_COUNT, 8).

-vc('$Id$ ').
-author('arcusfelis@gmail.com').

-include("ts_macros.hrl").

-behaviour(supervisor).

%% External exports
-export([start/0, choose_server/0]).

%% supervisor callbacks
-export([init/1]).

%%%----------------------------------------------------------------------
%%% API
%%%----------------------------------------------------------------------
start() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

choose_server() ->
    srv_name(random:uniform(?WORKERS_COUNT)).

srv_name(N) when is_integer(N) ->
    list_to_atom("ts_mon_cache_" ++ integer_to_list(N)).

%%%----------------------------------------------------------------------
%%% Callback functions from supervisor
%%%----------------------------------------------------------------------

%%----------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%%----------------------------------------------------------------------
init([]) ->
    ChildSpecs = [child_spec(N) || N <- lists:seq(1, ?WORKERS_COUNT)],
    {ok,{{one_for_one,?retries,10}, ChildSpecs}}.

%%%----------------------------------------------------------------------
%%% Internal functions
%%%----------------------------------------------------------------------

child_spec(N) ->
    Name = srv_name(N),
    {Name, {ts_mon_cache, start, [Name]},
        transient, 2000, worker, [ts_mon_cache]}.

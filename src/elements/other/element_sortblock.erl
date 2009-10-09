% Nitrogen Web Framework for Erlang
% Copyright (c) 2008-2009 Rusty Klophaus
% See MIT-LICENSE for licensing information.

-module (element_sortblock).
-include ("wf.inc").
-compile(export_all).

reflect() -> record_info(fields, sortblock).

render_element(HtmlID, Record) -> 
	% Get properties...
	Tag = Record#sortblock.tag,
	Trigger = Target = Record#sortblock.id,
	Delegate = Record#sortblock.delegate,
	PostbackInfo = wf_event:serialize_event_context({Delegate, Tag}, Trigger, Target, ?MODULE),
	Handle = case Record#sortblock.handle of
		undefined -> "null";
		Other -> wf:f("'.~s'", [Other])
	end,
	ConnectWithGroups = groups_to_connect_with(Record#sortblock.connect_with_groups),
	GroupClasses = groups_to_classes(Record#sortblock.group),
		
	% Emit the javascript...
	Script = #script { 
		script=wf:f("Nitrogen.$sortblock(obj('me'), { handle: ~s, connectWith: [~s] }, '~s');", [Handle, ConnectWithGroups, PostbackInfo])
	},
	wf:wire(Record#sortblock.id, Script),

	element_panel:render_element(HtmlID, #panel {
		class="sortblock " ++ GroupClasses ++ " " ++ wf:to_list(Record#sortblock.class),
		style=Record#sortblock.style,
		body=Record#sortblock.items
	}).

event({Delegate, BlockTag}) ->
	SortItems = wf:q(sort_items),
	SortTags = [wf:depickle(X) || X <- string:tokens(SortItems, ",")],
	Module = wf:coalesce([Delegate, wf:page_module()]),
	Module:sort_event(BlockTag, SortTags).

groups_to_classes([]) -> "";
groups_to_classes(undefined) -> "";
groups_to_classes(Groups) ->
	Groups1 = lists:flatten([Groups]),
	Groups2 = ["drag_group_" ++ wf:to_list(X) || X <- Groups1],
	string:join(Groups2, " ").
	
groups_to_connect_with(all) -> "'*'";
groups_to_connect_with(undefined) -> "'*'";
groups_to_connect_with(none) -> "";
groups_to_connect_with([]) -> "'*'";
groups_to_connect_with(Groups) ->
	Groups1 = lists:flatten([Groups]),
	Groups2 = ["'.drag_group_" ++ wf:to_list(X) ++ "'" || X <- Groups1],
	string:join(Groups2, ", ").
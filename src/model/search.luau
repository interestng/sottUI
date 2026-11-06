--!strict
-- subsequence match with a score that prefers word starts and tight runs, so "cr" finds "Cast range" over "Scarce"

local search = {}

local function isStart(text: string, at: number): boolean
	if at == 1 then
		return true
	end
	local before = string.sub(text, at - 1, at - 1)
	return before == " " or before == "/" or before == "-" or before == "_"
end

-- nil when query is not a subsequence of text; higher is better
function search.score(query: string, text: string): number?
	if query == "" then
		return 0
	end
	local haystack = string.lower(text)
	local needle = string.lower(query)
	local exact = string.find(haystack, needle, 1, true)
	if exact then
		return 1000 - #haystack + (if isStart(haystack, exact) then 500 else 0)
	end
	local score, cursor, last = 0, 1, -1
	for i = 1, #needle do
		local char = string.sub(needle, i, i)
		if char ~= " " then
			local found = string.find(haystack, char, cursor, true)
			if found == nil then
				return nil
			end
			score += if isStart(haystack, found) then 12 elseif found == last + 1 then 8 else 1
			score -= math.min(found - cursor, 6)
			last = found
			cursor = found + 1
		end
	end
	return score
end

-- a setting's name may match loosely; its page, section and tooltip only literally. a long tooltip contains most short
-- queries as a scattered subsequence, which floods results with things that have nothing to do with what was typed
function search.setting(query: string, el: any): number?
	local named = search.score(query, el.label)
	if named then
		return named + 100
	end
	local needle = string.lower(query)
	local section = el.section and el.section.title or ""
	local context = string.lower((el._pageName or "") .. " " .. section .. " " .. (el.tip or ""))
	return if string.find(context, needle, 1, true) then 1 else nil
end

function search.settings(query: string, items: { any }, limit: number): { any }
	local hits = {}
	for _, item in items do
		local score = search.setting(query, item)
		if score then
			table.insert(hits, { item = item, score = score })
		end
	end
	table.sort(hits, function(a, b)
		return a.score > b.score
	end)
	-- a key or colour draws inside its host's row, so a hit on one is a hit on that row: listing it again gave "Walk speed" twice
	local out, seen = {}, {}
	for _, hit in hits do
		local row = hit.item.host or hit.item
		if not seen[row] then
			seen[row] = true
			table.insert(out, row)
			if #out == limit then
				break
			end
		end
	end
	return out
end

export type Hit<T> = { item: T, score: number }

function search.rank<T>(query: string, items: { T }, text: (T) -> string, limit: number): { T }
	local hits: { Hit<T> } = {}
	for _, item in items do
		local score = search.score(query, text(item))
		if score then
			table.insert(hits, { item = item, score = score })
		end
	end
	table.sort(hits, function(a, b)
		return a.score > b.score
	end)
	local out = {}
	for i = 1, math.min(limit, #hits) do
		out[i] = hits[i].item
	end
	return out
end

return search

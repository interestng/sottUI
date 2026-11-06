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

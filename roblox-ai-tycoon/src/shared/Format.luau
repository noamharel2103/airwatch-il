--!strict
local Format = {}

local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
local DAYS_IN = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
Format.MONTHS = MONTHS

local function isLeap(y: number): boolean
	return (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0
end

function Format.daysInMonth(y: number, m: number): number
	if m == 2 and isLeap(y) then
		return 29
	end
	return DAYS_IN[m]
end

-- day index 0 = 2023-01-01
function Format.dateFromDay(day: number): (number, number, number)
	local y, m, d = 2023, 1, 1
	local left = math.floor(day)
	while true do
		local yl = isLeap(y) and 366 or 365
		if left >= yl then
			left -= yl
			y += 1
		else
			break
		end
	end
	while left >= Format.daysInMonth(y, m) do
		left -= Format.daysInMonth(y, m)
		m += 1
	end
	d += left
	return y, m, d
end

function Format.dayFromDate(y: number, m: number, d: number): number
	local day = 0
	for yy = 2023, y - 1 do
		day += isLeap(yy) and 366 or 365
	end
	for yy = y, 2022 do
		day -= isLeap(yy) and 366 or 365
	end
	for mm = 1, m - 1 do
		day += Format.daysInMonth(y, mm)
	end
	return day + d - 1
end

function Format.dayFromString(s: string): number
	local y, m, d = s:match("^(%d+)%-(%d+)%-?(%d*)")
	return Format.dayFromDate(tonumber(y) :: number, tonumber(m) :: number, tonumber(d) or 1)
end

function Format.date(day: number): string
	local y, m, d = Format.dateFromDay(day)
	return string.format("%s %d, %d", MONTHS[m], d, y)
end

function Format.monthYear(day: number): string
	local y, m = Format.dateFromDay(day)
	return MONTHS[m] .. " " .. y
end

function Format.money(n: number): string
	local neg = n < 0
	n = math.abs(n)
	local s
	if n >= 1e12 then
		s = string.format("%.2fT", n / 1e12)
	elseif n >= 1e9 then
		s = string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then
		s = string.format("%.2fM", n / 1e6)
	elseif n >= 1e4 then
		s = string.format("%.0fK", n / 1e3)
	else
		s = string.format("%.0f", n)
	end
	return (neg and "-$" or "$") .. s
end

function Format.count(n: number): string
	if n >= 1e9 then
		return string.format("%.1fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.1fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	end
	return tostring(math.floor(n))
end

function Format.pct(x: number): string
	return string.format("%.1f%%", x * 100)
end

return Format

local datetime = require 'datetime'

local digits = { }
local function inc(dig)
	digits[dig] = (digits[dig] or 0) + 1
end

local time = datetime.new()
local plus1min = datetime.interval.new{min = 1}
while true do
	local clock = time:totable()

	inc(math.floor(clock.hour / 10))
	inc(clock.hour % 10)
	inc(math.floor(clock.min / 10))
	inc(clock.min % 10)

	if clock.hour == 23 and clock.min == 59 then
		break
	end
	time:add(plus1min)
end

local hor = { [0] = 2, [1] = 0, [2] = 3, [3] = 3, [4] = 1, [5] = 3, [6] = 3, [7] = 1, [8] = 3, [9] = 3 }
local ver = { [0] = 4, [1] = 2, [2] = 2, [3] = 2, [4] = 3, [5] = 2, [6] = 3, [7] = 2, [8] = 4, [9] = 3 }

print('digit', 'count', 'horiz', 'vert')
print('-----', '-----', '-----', '-----')
local sum = 0
local sum_hor = 0
local sum_ver = 0
for dig, cnt in pairs(digits) do
	sum = sum + cnt
	sum_hor = sum_hor + hor[dig] * cnt
	sum_ver = sum_ver + ver[dig] * cnt
	print(dig, cnt, hor[dig] * cnt, ver[dig] * cnt)
end
print('-----', '-----', '-----', '-----')
print('sum:', sum, sum_hor, sum_ver)

local bit = require('bit')
local fio = require('fio')
local yaml = require('yaml')
local lz4 = require('compress').lz4.new({
    acceleration = tonumber(arg[1]),
})
local block_size = tonumber(arg[2])

local schema_yaml = [[
table1:
- {data_type: u32, unused: 0, name: c1}
- {data_type: utf8, unused: 0, name: c2}
- {data_type: utf8, unused: 0, name: c3}
- {data_type: i64, unused: 0, name: c4}
- {data_type: utf8, unused: 0, name: c5}
- {data_type: utf8, unused: 0, name: c6}
- {data_type: f32, unused: 0, name: c7}
- {data_type: utf8, unused: 0, name: c8}
- {data_type: utf8, unused: 0, name: c9}
- {data_type: f64, unused: 0, name: c10}
- {data_type: utf8, unused: 0, name: c11}
- {data_type: utf8, unused: 0, name: c12}
table2:
- {data_type: utf8, unused: 0, name: c1}
- {data_type: i64, unused: 0, name: c2}
- {data_type: u32, unused: 0, name: c3}
- {data_type: utf8, unused: 0, name: c4}
- {data_type: utf8, unused: 0, name: c5}
- {data_type: utf8, unused: 0, name: c6}
]]

function int8_to_bytes_le(n)
    local b1 = n % 256
    return string.char(b1)
end

function int16_to_bytes_le(n)
    local b1 = n % 256
    local b2 = math.floor(n / 256) % 256
    return string.char(b1, b2)
end

local function int32_to_bytes_le(n)
    local b1 = n % 256
    n = math.floor(n / 256)
    local b2 = n % 256
    n = math.floor(n / 256)
    local b3 = n % 256
    n = math.floor(n / 256)
    local b4 = n % 256
    return string.char(b1, b2, b3, b4)
end

function int64_to_bytes_le(n)
    local bytes = {}
    for i = 1, 8 do
        bytes[i] = n % 256
        n = math.floor(n / 256)
    end
    return string.char(unpack(bytes))
end

function encode_validity(bit_array)
    local result = {}
    for i = 1, #bit_array, 8 do
        local byte = 0
        for j = 0, 7 do
            local bit_val = bit_array[i + j] or 0
            byte = bit.bor(bit.lshift(byte, 1), bit_val)
        end
        table.insert(result, string.char(byte))
    end
    return table.concat(result)
end

function encode_numbers(table, type_size)
    local res = ''
    for _, num in ipairs(table) do
        if type_size == 1 then
            res = res .. int8_to_bytes_le(num)
        elseif type_size == 2 then
            res = res .. int16_to_bytes_le(num)
        elseif type_size == 4 then
            res = res .. int32_to_bytes_le(num)
        elseif type_size == 8 then
            res = res .. int64_to_bytes_le(num)
        else
            error()
        end
    end
    return res
end

function process_data(validity, numbers, type_size)
    local encoded = ''
    encoded = encoded .. encode_validity(validity)
    encoded = encoded .. encode_numbers(numbers, type_size)
    local compressed = lz4:compress(encoded)
    return encoded:len(), compressed:len()
end

function process_column(table_name, column_name, file_path, type_size, block_size)
    local f = io.open(file_path, 'r')
    if f:read() ~= column_name then
        os.exit()
    end
    local count = 0
    local validity = {}
    local numbers = {}
    local sz1 = 0
    local sz2 = 0
    local size1 = 0
    local size2 = 0
    for line in f:lines() do
        if line == '""' then
            validity[count] = 0
            numbers[count] = 0
        else
            validity[count] = 1
            numbers[count] = tonumber(line)
        end
        count = count + 1
        if count == block_size then
            sz1, sz2 = process_data(validity, numbers, type_size)
            size1 = size1 + sz1
            size2 = size2 + sz2
            count = 0
            validity = {}
            numbers = {}
        end
    end
    sz1, sz2 = process_data(validity, numbers, type_size)
    size1 = size1 + sz1
    size2 = size2 + sz2
    f:close()
    io.write(table_name .. ';' .. column_name .. ';' .. size1 .. ';' .. size2 .. ';\n')
    io.flush()
end

local tables_path = '/ssd/1234/csv/numbers/'
local schema = yaml.decode(schema_yaml)

for table_name, columns in pairs(schema) do
    for _, column in pairs(columns) do
        local column_name = column['name']
        local type = column['data_type']
        if type ~= 'utf8' then
            local type_size = tonumber(string.sub(type, 2)) / 8
            local file_path = fio.pathjoin(tables_path, table_name, column_name .. '.csv')
            process_column(table_name, column_name, file_path, type_size, block_size)
        end
    end
end

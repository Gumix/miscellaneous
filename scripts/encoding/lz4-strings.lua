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

function encode_offsets(strings)
    local offset = 0
    local result = int32_to_bytes_le(offset)
    for i, str in ipairs(strings) do
        offset = offset + #str
        result = result .. int32_to_bytes_le(offset)
    end
    return result
end

function encode_strings(strings)
    local result = ''
    for _, str in ipairs(strings) do
        result = result .. str
    end
    return result
end

function process_non_view(validity, strings)
    local encoded = ''
    encoded = encoded .. encode_validity(validity)
    encoded = encoded .. encode_offsets(strings)
    encoded = encoded .. encode_strings(strings)
    local compressed = lz4:compress(encoded)
    return encoded:len(), compressed:len()
end

function encode_german(strings)
    local result = ''
    local some_ptr = 0x12345678
    for _, str in ipairs(strings) do
        local encoded = int32_to_bytes_le(#str)
        if #str <= 12 then
            encoded = encoded .. str
            encoded = encoded .. string.rep(string.char(0), 12 - #str)
        else
            encoded = encoded .. string.sub(str, 1, 4)
            encoded = encoded .. int32_to_bytes_le(0x55555555)
            encoded = encoded .. int32_to_bytes_le(some_ptr)
            some_ptr = some_ptr + 32
        end
        result = result .. encoded
    end
    return result
end

function encode_external(strings)
    local result = 0
    for _, str in ipairs(strings) do
        if #str > 12 then
            result = result + #str + 3
        end
    end
    return result
end

function process_view(validity, strings)
    local encoded = ''
    encoded = encoded .. encode_validity(validity)
    encoded = encoded .. encode_german(strings)
    local compressed = lz4:compress(encoded)
    local ext_size = encode_external(strings)
    return encoded:len() + ext_size, compressed:len() + ext_size
end

function process_column(table_name, column_name, file_path, block_size)
    local f = io.open(file_path, 'r')
    if f:read() ~= column_name then
        os.exit()
    end
    local count = 0
    local validity = {}
    local strings = {}
    local sizes = { 0, 0, 0, 0}
    for line in f:lines() do
        count = count + 1
        if line == '""' then
            validity[count] = 0
            strings[count] = ''
        else
            validity[count] = 1
            strings[count] = line
        end
        if count == block_size then
            local sz1, sz2 = process_non_view(validity, strings)
            sizes[1] = sizes[1] + sz1
            sizes[2] = sizes[2] + sz2
            local sz1, sz2 = process_view(validity, strings)
            sizes[3] = sizes[3] + sz1
            sizes[4] = sizes[4] + sz2
            count = 0
            validity = {}
            strings = {}
        end
    end
    local sz1, sz2 = process_non_view(validity, strings)
    sizes[1] = sizes[1] + sz1
    sizes[2] = sizes[2] + sz2
    local sz1, sz2 = process_view(validity, strings)
    sizes[3] = sizes[3] + sz1
    sizes[4] = sizes[4] + sz2
    f:close()
    io.write(table_name .. ';' .. column_name .. ';')
    io.write(sizes[1] .. ';' .. sizes[2] .. ';')
    io.write(sizes[3] .. ';' .. sizes[4] .. ';\n')
    io.flush()
end

local tables_path = '/ssd/1234/csv/strings/'
local schema = yaml.decode(schema_yaml)

for table_name, columns in pairs(schema) do
    for _, column in pairs(columns) do
        local column_name = column['name']
        local type = column['data_type']
        if type == 'utf8' then
            local file_path = fio.pathjoin(tables_path, table_name, column_name .. '.csv')
            process_column(table_name, column_name, file_path, block_size)
        end
    end
end

local fio = require('fio')
local yaml = require('yaml')

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

local layouts = {
    ['primitive'] = {}, ['rle_null'] = {}, ['ree_full'] = {},
    ['dict_8'] = {}, ['dict_16'] = {}, ['dict_32'] = {},
}

function layouts.primitive:init(type_size)
    self.type_size = type_size
    self.count = 0
end

function layouts.rle_null:init(type_size)
    self.type_size = type_size
    self.count = 0
    self.prev = nil
end

function layouts.dict_8:init(type_size)
    self.key_size = 1
    self.max_dict_count = 256
    self.value_size = type_size
    self.count = 0
    self.dict = {}
end

function layouts.dict_16:init(type_size)
    self.key_size = 2
    self.max_dict_count = 65536
    self.value_size = type_size
    self.count = 0
    self.dict = {}
end

function layouts.dict_32:init(type_size)
    self.key_size = 4
    self.max_dict_count = 4294967296
    self.value_size = type_size
    self.count = 0
    self.dict = {}
end

function layouts.ree_full:init(type_size)
    self.type_size = type_size
    self.index_size = 2
    self.count = 0
    self.prev = nil
end

function layouts.primitive:add(num)
    self.count = self.count + 1
end

function layouts.rle_null:add(num)
    if (self.prev ~= num or num ~= '""') then
        self.count = self.count + 1
    end
    self.prev = num
end

function layouts.ree_full:add(num)
    if (self.prev ~= num) then
        self.count = self.count + 1
    end
    self.prev = num
end

function layouts.dict_8:add(num)
    self.count = self.count + 1
    self.dict[num] = true
end

function layouts.dict_16:add(num)
    self.count = self.count + 1
    self.dict[num] = true
end

function layouts.dict_32:add(num)
    self.count = self.count + 1
    self.dict[num] = true
end

function layouts.primitive:fini()
    local size = math.ceil(self.count * (self.type_size + 1/8))
    return size
end

function layouts.rle_null:fini()
    local size = math.ceil(self.count * (self.type_size + 1/8))
    return size
end

function layouts.ree_full:fini()
    local size = math.ceil(self.count * (self.type_size + self.index_size + 1/8))
    return size
end

function layouts.dict_8:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * self.value_size)
    return size
end

function layouts.dict_16:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * self.value_size)
    return size
end

function layouts.dict_32:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * self.value_size)
    return size
end

function process_column(table_name, column_name, file_path, type_size)
    local f = io.open(file_path, 'r')
    if f:read() ~= column_name then
        os.exit()
    end
    for _, layout in pairs(layouts) do
        layout:init(type_size)
    end
    for line in f:lines() do
        for _, layout in pairs(layouts) do
            layout:add(line)
        end
    end
    f:close()
    io.write(table_name .. ';' .. column_name .. ';')
    for _, layout in pairs(layouts) do
        local size = layout:fini()
        io.write(size .. ';')
    end
    print()
end

local tables_path = '/ssd/1234/csv/numbers/'
local schema = yaml.decode(schema_yaml)

for layout in pairs(layouts) do
    io.write(layout .. ';')
end
print()

for table_name, columns in pairs(schema) do
    for _, column in pairs(columns) do
        local column_name = column['name']
        local type = column['data_type']
        if type ~= 'utf8' then
            local type_size = tonumber(string.sub(type, 2)) / 8
            local file_path = fio.pathjoin(tables_path, table_name, column_name .. '.csv')
            process_column(table_name, column_name, file_path, type_size)
        end
    end
end

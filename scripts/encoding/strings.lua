local log = require('log')
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
    ['non_view'] = {}, ['mp_ext'] = {},
    ['view'] = {}, ['view_rle_null'] = {}, ['view_ree_full'] = {},
    ['fixed'] = {}, ['fixed_rle_null'] = {}, ['fixed_ree_full'] = {},
    ['decimal'] = {}, ['decimal_rle_null'] = {}, ['decimal_ree_full'] = {},
    ['view_dict_8'] = {}, ['view_dict_16'] = {}, ['view_dict_32'] = {},
    ['fixed_dict_8'] = {}, ['fixed_dict_16'] = {}, ['fixed_dict_32'] = {},
    ['decimal_dict_8'] = {}, ['decimal_dict_16'] = {}, ['decimal_dict_32'] = {},
}

function layouts.non_view:init()
    self.count = 1
    self.offset_type_size = 4
    self.data_size = 0
end

function layouts.mp_ext:init()
    self.count = 0
    self.ptr_size = 8
    self.ext_data_size = 0
end

function layouts.view:init()
    self.count = 0
    self.type_size = 16
    self.ext_data_size = 0
end

function layouts.view_rle_null:init()
    self.count = 0
    self.type_size = 16
    self.ext_data_size = 0
    self.prev = nil
end

function layouts.view_ree_full:init()
    self.count = 0
    self.type_size = 16
    self.index_size = 2
    self.ext_data_size = 0
    self.prev = nil
end

function layouts.view_dict_8:init()
    self.count = 0
    self.key_size = 1
    self.max_dict_count = 256
    self.type_size = 16
    self.ext_data_size = 0
    self.dict = {}
end

function layouts.view_dict_16:init()
    self.count = 0
    self.key_size = 2
    self.max_dict_count = 65536
    self.type_size = 16
    self.ext_data_size = 0
    self.dict = {}
end

function layouts.view_dict_32:init()
    self.count = 0
    self.key_size = 4
    self.max_dict_count = 4294967296
    self.type_size = 16
    self.ext_data_size = 0
    self.dict = {}
end

function layouts.fixed:init()
    self.count = 0
    self.max_len = 0
end

function layouts.fixed_rle_null:init()
    self.count = 0
    self.max_len = 0
    self.prev = nil
end

function layouts.fixed_ree_full:init()
    self.count = 0
    self.index_size = 2
    self.max_len = 0
    self.prev = nil
end

function layouts.fixed_dict_8:init()
    self.count = 0
    self.key_size = 1
    self.max_dict_count = 256
    self.max_len = 0
    self.dict = {}
end

function layouts.fixed_dict_16:init()
    self.count = 0
    self.key_size = 2
    self.max_dict_count = 65536
    self.max_len = 0
    self.dict = {}
end

function layouts.fixed_dict_32:init()
    self.count = 0
    self.key_size = 4
    self.max_dict_count = 4294967296
    self.max_len = 0
    self.dict = {}
end

function layouts.decimal:init()
    self.is_num = true
    self.count = 0
    self.max_len = 0
end

function layouts.decimal_rle_null:init()
    self.is_num = true
    self.count = 0
    self.max_len = 0
    self.prev = nil
end

function layouts.decimal_ree_full:init()
    self.is_num = true
    self.count = 0
    self.index_size = 2
    self.max_len = 0
    self.prev = nil
end

function layouts.decimal_dict_8:init()
    self.is_num = true
    self.count = 0
    self.key_size = 1
    self.max_dict_count = 256
    self.max_len = 0
    self.dict = {}
end

function layouts.decimal_dict_16:init()
    self.is_num = true
    self.count = 0
    self.key_size = 2
    self.max_dict_count = 65536
    self.max_len = 0
    self.dict = {}
end

function layouts.decimal_dict_32:init()
    self.is_num = true
    self.count = 0
    self.key_size = 4
    self.max_dict_count = 4294967296
    self.max_len = 0
    self.dict = {}
end

function layouts.non_view:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    self.data_size = self.data_size + len
end

function layouts.mp_ext:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    self.ext_data_size = self.ext_data_size + len + 3
end

function layouts.view:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    if len > 12 then
        self.ext_data_size = self.ext_data_size + len + 3
    end
end

function layouts.view_rle_null:add(str)
    local len = str == '""' and 0 or #str
    if (self.prev ~= str or len > 0) then
        self.count = self.count + 1
            if len > 12 then
                self.ext_data_size = self.ext_data_size + len + 3
        end
    end
    self.prev = str
end

function layouts.view_ree_full:add(str)
    local len = str == '""' and 0 or #str
    if (self.prev ~= str) then
        self.count = self.count + 1
            if len > 12 then
                self.ext_data_size = self.ext_data_size + len + 3
        end
    end
    self.prev = str
end

function layouts.view_dict_8:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    if self.dict[str] == nil and len > 12 then
        self.ext_data_size = self.ext_data_size + len + 3
    end
    self.dict[str] = true
end

function layouts.view_dict_16:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    if self.dict[str] == nil and len > 12 then
        self.ext_data_size = self.ext_data_size + len + 3
    end
    self.dict[str] = true
end

function layouts.view_dict_32:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    if self.dict[str] == nil and len > 12 then
        self.ext_data_size = self.ext_data_size + len + 3
    end
    self.dict[str] = true
end

function layouts.fixed:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    if self.max_len < len then
        self.max_len = len
    end
end

function layouts.fixed_rle_null:add(str)
    local len = str == '""' and 0 or #str
    if (self.prev ~= str or len > 0) then
        self.count = self.count + 1
        if self.max_len < len then
            self.max_len = len
        end
    end
    self.prev = str
end

function layouts.fixed_ree_full:add(str)
    local len = str == '""' and 0 or #str
    if (self.prev ~= str) then
        self.count = self.count + 1
        if self.max_len < len then
            self.max_len = len
        end
    end
    self.prev = str
end

function layouts.fixed_dict_8:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    if self.max_len < len then
        self.max_len = len
    end
    self.dict[str] = true
end

function layouts.fixed_dict_16:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    if self.max_len < len then
        self.max_len = len
    end
    self.dict[str] = true
end

function layouts.fixed_dict_32:add(str)
    local len = str == '""' and 0 or #str
    self.count = self.count + 1
    if self.max_len < len then
        self.max_len = len
    end
    self.dict[str] = true
end

function layouts.decimal:add(str)
    if not self.is_num then
        return
    end
    local len = str == '""' and 0 or #str
    if len > 0 and tonumber(str) == nil then
        self.is_num = false
        return
    end
    self.count = self.count + 1
    if self.max_len < len then
        self.max_len = len
    end
end

function layouts.decimal_rle_null:add(str)
    if not self.is_num then
        return
    end
    local len = str == '""' and 0 or #str
    if len > 0 and tonumber(str) == nil then
        self.is_num = false
        return
    end
    if (self.prev ~= str or len > 0) then
        self.count = self.count + 1
        if self.max_len < len then
            self.max_len = len
        end
    end
    self.prev = str
end

function layouts.decimal_ree_full:add(str)
    if not self.is_num then
        return
    end
    local len = str == '""' and 0 or #str
    if len > 0 and tonumber(str) == nil then
        self.is_num = false
        return
    end
    if (self.prev ~= str) then
        self.count = self.count + 1
        if self.max_len < len then
            self.max_len = len
        end
    end
    self.prev = str
end

function layouts.decimal_dict_8:add(str)
    if not self.is_num then
        return
    end
    local len = str == '""' and 0 or #str
    if len > 0 and tonumber(str) == nil then
        self.is_num = false
        return
    end
    self.count = self.count + 1
    if self.max_len < len then
        self.max_len = len
    end
    self.dict[str] = true
end

function layouts.decimal_dict_16:add(str)
    if not self.is_num then
        return
    end
    local len = str == '""' and 0 or #str
    if len > 0 and tonumber(str) == nil then
        self.is_num = false
        return
    end
    self.count = self.count + 1
    if self.max_len < len then
        self.max_len = len
    end
    self.dict[str] = true
end

function layouts.decimal_dict_32:add(str)
    if not self.is_num then
        return
    end
    local len = str == '""' and 0 or #str
    if len > 0 and tonumber(str) == nil then
        self.is_num = false
        return
    end
    self.count = self.count + 1
    if self.max_len < len then
        self.max_len = len
    end
    self.dict[str] = true
end

function layouts.non_view:fini()
    local size = math.ceil(self.count * (self.offset_type_size + 1/8) +
                           self.data_size)
    return size
end

function layouts.mp_ext:fini()
    local size = math.ceil(self.count * (self.ptr_size + 1/8) +
                           self.ext_data_size)
    return size
end

function layouts.view:fini()
    local size = math.ceil(self.count * (self.type_size + 1/8) +
                           self.ext_data_size)
    return size
end

function layouts.view_rle_null:fini()
    local size = math.ceil(self.count * (self.type_size + 1/8) +
                           self.ext_data_size)
    return size
end

function layouts.view_ree_full:fini()
    local size = math.ceil(self.count * (self.type_size + self.index_size + 1/8) +
                           self.ext_data_size)
    return size
end

function layouts.view_dict_8:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * self.type_size + self.ext_data_size)
    return size
end

function layouts.view_dict_16:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * self.type_size + self.ext_data_size)
    return size
end

function layouts.view_dict_32:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * self.type_size + self.ext_data_size)
    return size
end

function layouts.fixed:fini()
    if self.max_len > 32 then
        return -1
    end
    local type_size
    if self.max_len > 16 then
        type_size = 32
    elseif self.max_len > 8 then
        type_size = 16
    elseif self.max_len > 4 then
        type_size = 8
    elseif self.max_len > 2 then
        type_size = 4
    elseif self.max_len > 1 then
        type_size = 2
    else
        type_size = 1
    end
    local size = math.ceil(self.count * (type_size + 1/8))
    return size
end

function layouts.fixed_rle_null:fini()
    if self.max_len > 32 then
        return -1
    end
    local type_size
    if self.max_len > 16 then
        type_size = 32
    elseif self.max_len > 8 then
        type_size = 16
    elseif self.max_len > 4 then
        type_size = 8
    elseif self.max_len > 2 then
        type_size = 4
    elseif self.max_len > 1 then
        type_size = 2
    else
        type_size = 1
    end
    local size = math.ceil(self.count * (type_size + 1/8))
    return size
end

function layouts.fixed_ree_full:fini()
    if self.max_len > 32 then
        return -1
    end
    local type_size
    if self.max_len > 16 then
        type_size = 32
    elseif self.max_len > 8 then
        type_size = 16
    elseif self.max_len > 4 then
        type_size = 8
    elseif self.max_len > 2 then
        type_size = 4
    elseif self.max_len > 1 then
        type_size = 2
    else
        type_size = 1
    end
    local size = math.ceil(self.count * (type_size + self.index_size + 1/8))
    return size
end

function layouts.fixed_dict_8:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local type_size
    if self.max_len > 16 then
        type_size = 32
    elseif self.max_len > 8 then
        type_size = 16
    elseif self.max_len > 4 then
        type_size = 8
    elseif self.max_len > 2 then
        type_size = 4
    elseif self.max_len > 1 then
        type_size = 2
    else
        type_size = 1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * type_size)
    return size
end

function layouts.fixed_dict_16:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local type_size
    if self.max_len > 16 then
        type_size = 32
    elseif self.max_len > 8 then
        type_size = 16
    elseif self.max_len > 4 then
        type_size = 8
    elseif self.max_len > 2 then
        type_size = 4
    elseif self.max_len > 1 then
        type_size = 2
    else
        type_size = 1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * type_size)
    return size
end

function layouts.fixed_dict_32:fini()
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local type_size
    if self.max_len > 16 then
        type_size = 32
    elseif self.max_len > 8 then
        type_size = 16
    elseif self.max_len > 4 then
        type_size = 8
    elseif self.max_len > 2 then
        type_size = 4
    elseif self.max_len > 1 then
        type_size = 2
    else
        type_size = 1
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * type_size)
    return size
end

function layouts.decimal:fini()
    if not self.is_num or self.max_len > 18 then
        return -1
    end
    local type_size
    if self.max_len > 9 then
        type_size = 8
    else
        type_size = 4
    end
    local size = math.ceil(self.count * (type_size + 1/8))
    return size
end

function layouts.decimal_rle_null:fini()
    if not self.is_num or self.max_len > 18 then
        return -1
    end
    local type_size
    if self.max_len > 9 then
        type_size = 8
    else
        type_size = 4
    end
    local size = math.ceil(self.count * (type_size + 1/8))
    return size
end

function layouts.decimal_ree_full:fini()
    if not self.is_num or self.max_len > 18 then
        return -1
    end
    local type_size
    if self.max_len > 9 then
        type_size = 8
    else
        type_size = 4
    end
    local size = math.ceil(self.count * (type_size + self.index_size + 1/8))
    return size
end

function layouts.decimal_dict_8:fini()
    if not self.is_num or self.max_len > 18 then
        return -1
    end
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local type_size
    if self.max_len > 9 then
        type_size = 8
    else
        type_size = 4
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * type_size)
    return size
end

function layouts.decimal_dict_16:fini()
    if not self.is_num or self.max_len > 18 then
        return -1
    end
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local type_size
    if self.max_len > 9 then
        type_size = 8
    else
        type_size = 4
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * type_size)
    return size
end

function layouts.decimal_dict_32:fini()
    if not self.is_num or self.max_len > 18 then
        return -1
    end
    local dict_count = 0
    for _ in pairs(self.dict) do
        dict_count = dict_count + 1
    end
    if dict_count > self.max_dict_count then
        return -1
    end
    local type_size
    if self.max_len > 9 then
        type_size = 8
    else
        type_size = 4
    end
    local size = math.ceil(self.count * (self.key_size + 1/8) +
                           dict_count * type_size)
    return size
end

function process_column(table_name, column_name, file_path)
    local f = io.open(file_path, 'r')
    if f:read() ~= column_name then
        os.exit()
    end
    for _, layout in pairs(layouts) do
        layout:init()
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

local tables_path = '/ssd/1234/csv/strings/'
local schema = yaml.decode(schema_yaml)

for layout in pairs(layouts) do
    io.write(layout .. ';')
end
print()

for table_name, columns in pairs(schema) do
    for _, column in pairs(columns) do
        local column_name = column['name']
        local type = column['data_type']
        if type == 'utf8' then
            local file_path = fio.pathjoin(tables_path, table_name, column_name .. '.csv')
            process_column(table_name, column_name, file_path)
        end
    end
end

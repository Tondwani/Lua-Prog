-- Helper function to load the grid from grid.txt
local function loadGrid(filename)
    local grid = {}
    for line in io.lines(filename) do
        for colIndex, values in line:gmatch("%((%d+)%s*|%s*([%d%s]+)%)") do
            colIndex = tonumber(colIndex)
            for rowIndex, value in ipairs({values:match("(%d+)")}) do
                grid[rowIndex] = grid[rowIndex] or {}
                grid[rowIndex][colIndex] = tonumber(value)
            end
        end
    end
    return grid
end

-- Helper function to load the graph from graph.txt
local function loadGraph(filename)
    local graph = {}
    for line in io.lines(filename) do
        local node, neighbors = line:match("<%s*(%a+)%s*|%s*([%a%s]*)%s*>")
        if node then
            graph[node] = {}
            for neighbor in neighbors:gmatch("%a+") do
                table.insert(graph[node], neighbor)
            end
        end
    end
    return graph
end

-- Grid Operations
local function numrows(grid)
    return #grid
end

local function numcols(grid)
    return #grid[1]
end

local function showrow(grid, row)
    if not grid[row] then return "Row not found" end
    local rowData = {}
    for _, val in ipairs(grid[row]) do
        table.insert(rowData, val or "nil")
    end
    return table.concat(rowData, " ")
end

local function showcol(grid, col)
    local colData = {}
    for i = 1, #grid do
        colData[#colData + 1] = grid[i][col] or "nil"
    end
    return table.concat(colData, " ")
end

local function showcell(grid, row, col)
    return grid[row] and grid[row][col] or "Cell not found"
end

-- Graph Operations
local function numpathsfrom(graph, node)
    if not graph[node] then return 0 end
    local visited = {}
    local function dfs(v)
        if visited[v] then return 0 end
        visited[v] = true
        local paths = 1
        for _, neighbor in ipairs(graph[v]) do
            paths = paths + dfs(neighbor)
        end
        visited[v] = false
        return paths
    end
    return dfs(node) - 1
end

local function pathsfrom(graph, node)
    if not graph[node] then return "No paths" end
    local paths = {}
    local function dfs(path)
        local current = path[#path]
        if not graph[current] or #graph[current] == 0 then
            table.insert(paths, table.concat(path, " -> "))
            return
        end
        for _, neighbor in ipairs(graph[current]) do
            if not table.contains(path, neighbor) then
                local newPath = {table.unpack(path)}
                table.insert(newPath, neighbor)
                dfs(newPath)
            end
        end
    end
    dfs({node})
    return table.concat(paths, "\n")
end

-- Command Execution
local function executeCommand(grid, graph, command, ...)
    if command == "numrows" then
        print(numrows(grid))
    elseif command == "numcols" then
        print(numcols(grid))
    elseif command == "showrow" then
        print(showrow(grid, tonumber(...)))
    elseif command == "showcol" then
        print(showcol(grid, tonumber(...)))
    elseif command == "showcell" then
        local args = {...}
        print(showcell(grid, tonumber(args[1]), tonumber(args[2])))
    elseif command == "numpathsfrom" then
        print(numpathsfrom(graph, ...))
    elseif command == "pathsfrom" then
        print(pathsfrom(graph, ...))
    else
        print("Invalid command")
    end
end

-- Main Program
local grid = loadGrid("grid.txt")
local graph = loadGraph("graph.txt")

print("Enter commands:")
while true do
    local input = io.read()
    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end
    if args[1] == "exit" then break end
    executeCommand(grid, graph, table.unpack(args))
end

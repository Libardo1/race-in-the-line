local json = require("json")

local settingsLoader = {}

function settingsLoader.saveTable(t, filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end

function settingsLoader.loadTable(filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
         local contents = file:read( "*a" )
         myTable = json.decode(contents)
         io.close( file )
         return myTable 
    end
    return nil
end

return settingsLoader

local ByteArray = require "framework.utils.ByteArray"

local packBody = class("packBody")
function packBody:ctor(code, uid, pnum, mapid, syncid)
    self.opCode = code
    self.uID = uid
    self.packNumber = pnum
    self.indexMapID = mapid
    self.syncID = syncid
end

function packBody:bufferIn()
    local buf = ByteArray.new():writeUInt(self.opCode or 0):writeUInt(self.uID or 0):writeUShort(self.packNumber or 0):
        writeUInt(self.indexMapID or 0):writeUInt(self.syncID or 0)
    print(ByteArray.toString(buf))    
    return buf
end

function packBody:toString()
    return string.format("op is %d, indexMapID is %d, syncID is %d", self.opCode, self.indexMapID, self.syncID)
end

return packBody
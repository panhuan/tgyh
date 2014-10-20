local base64url = {}
function base64url.encode(text)
  return MOAIDataBuffer.base64Encode(text):gsub("[+]", "-"):gsub("/", "_"):gsub("=", "%%3D")
end
function base64url.decode(text)
  return MOAIDataBuffer.base64Decode(text:gsub("%%3D", "="):gsub("_", "/"):gsub("-", "+"))
end
return base64url

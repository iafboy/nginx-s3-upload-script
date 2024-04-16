local aws = require "resty.aws"
local s3 = aws.s3("YOUR_ACCESS_KEY", "YOUR_SECRET_KEY", "us-east-1")

local bucket = "YOUR_BUCKET"
local object_key = ngx.var.arg_object_key
local file_path = ngx.var.arg_file_path

local file = io.open(file_path, "rb")
if not file then
    ngx.status = 400
    ngx.say("Failed to open file")
    ngx.exit(ngx.status)
end

local file_content = file:read("*a")
file:close()

local response = s3:put_object(bucket, object_key, file_content)
if response.status == 200 then
    ngx.say("File uploaded successfully")
else
    ngx.status = response.status
    ngx.say("Failed to upload file: ", response.body)
end

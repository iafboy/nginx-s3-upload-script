-- s3_put.lua

local aws = require "resty.aws"
local s3 = aws.s3("YOUR_ACCESS_KEY", "YOUR_SECRET_KEY", "us-east-1")

local bucket = "YOUR_BUCKET"
local object_key = ngx.var.arg_object_key
local file_content = ngx.req.get_body_data() or ""

-- 生成 PUT 请求的签名
local headers = {}
local response = s3:sign("PUT", bucket, object_key, headers)

-- 构建 S3 API 请求
local s3_url = "https://" .. bucket .. ".s3.amazonaws.com/" .. object_key
local request_headers = {
    ["Authorization"] = response.headers["Authorization"],
    ["x-amz-date"] = response.headers["x-amz-date"],
    ["Content-Length"] = tostring(#file_content),
}

-- 发送 PUT 请求到 S3
local http = require "resty.http"
local httpc = http.new()
local res, err = httpc:request_uri(s3_url, {
    method = "PUT",
    headers = request_headers,
    body = file_content,
    ssl_verify = true,  -- 根据实际情况配置是否验证 SSL 证书
})

-- 处理 S3 响应
if not res then
    ngx.status = 500
    ngx.say("Failed to send request to S3: ", err)
    ngx.exit(ngx.status)
end

ngx.status = res.status
ngx.say(res.body)

build :buildpack_cache do
  
  BUILDPACK_CACHE_NAME = "buildpack_cache.tar.gz"
  BUILDPACK_CACHE_URL  = "http://file.ebcloud.com/buildpack_cache/#{BUILDPACK_CACHE_NAME}"

  # 下载cache文件并解压
  run "curl #{BUILDPACK_CACHE_URL} -s -o #{BUILDPACK_CACHE_NAME}"
  run "tar zxvf #{BUILDPACK_CACHE_NAME}"

  move_to_target 'buildpack_cache', nil, false
end
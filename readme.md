尝试模拟GaussDB的高级包接口，以便使用了GaussDB的高级包接口的项目能在不改写代码的情况下迁移到openGauss或其他基于openGauss的商业数据库
  
由于dbe开头的部分schema名称在openGauss中是被限制使用的，因此新建的对应的schema名称前加上了mog_（可以批量正则替换）
  
test目录下是从openGauss中拿到的使用了dbe包的测试sql及输出结果，实际上在openGauss中不可能得到这个输出结果，但使用了本项目模拟的包后，就可以得到这个输出结果了
比如运行pljson.sql，能得到相同的out结果

目前已支持的
dbe_application_info
dbe_lob
dbe_output
dbe_random
dbe_raw
dbe_utility
dbe_task

目前未改完的还有
dbe_file (orafce > utl_file)
dbe_schedule
dbe_match (compat-tools >utl_match)
dbe_session
dbe_sql
dbe_lob(与文件相关的部分)
dbe_utility(与堆栈相关的部分)